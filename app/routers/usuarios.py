from typing import Any, Dict, List, Optional
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field, EmailStr, field_validator
import pymysql
import secrets
from datetime import datetime, timedelta

from app.db.database import get_connection
from app.core.security import hash_password
from app.core.deps import require_active_user, require_roles

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


# =========================
# MODELOS
# =========================

class RegistroUsuario(BaseModel):
    nombre_completo: str = Field(..., min_length=2, max_length=150)
    correo: EmailStr
    password: str = Field(..., min_length=6, description="Mínimo 6 caracteres")
    fecha_nacimiento: Optional[str] = Field(
        None, description="Formato obligatorio: YYYY-MM-DD (ej: 2003-08-25)"
    )
    tipo_documento: Optional[str] = Field(None, max_length=20, description="Ej: CC, CE, TI")
    numero_documento: Optional[str] = Field(None, max_length=50)
    telefono: Optional[str] = Field(None, max_length=20)
    pais: Optional[str] = Field(None, max_length=80)
    ciudad: Optional[str] = Field(None, max_length=80)
    direccion: Optional[str] = Field(None, max_length=150)

    @field_validator("fecha_nacimiento")
    @classmethod
    def validar_fecha(cls, v):
        if v is None:
            return v
        try:
            datetime.strptime(v, "%Y-%m-%d")
        except ValueError:
            raise ValueError(
                "Formato de fecha incorrecto. Usa YYYY-MM-DD (ej: 2003-08-25)"
            )
        return v


class ActualizarPerfil(BaseModel):
    nombre_completo: Optional[str] = Field(None, min_length=2, max_length=150)
    telefono: Optional[str] = Field(None, max_length=20)
    pais: Optional[str] = Field(None, max_length=80)
    ciudad: Optional[str] = Field(None, max_length=80)
    direccion: Optional[str] = Field(None, max_length=150)


class CambiarEstadoCuenta(BaseModel):
    id_estado_cuenta: int = Field(
        ..., ge=1, le=4,
        description="1=ACTIVO, 2=INACTIVO, 3=SUSPENDIDO, 4=PENDIENTE"
    )


class SolicitarRecuperacion(BaseModel):
    correo: EmailStr


class RestablecerContrasena(BaseModel):
    token: str = Field(..., min_length=1)
    nueva_password: str = Field(..., min_length=6)


# =========================
# REGISTRO PÚBLICO
# =========================

@router.post(
    "/registro",
    status_code=201,
    summary="Registro público de ciudadanos (sin token)"
)
def registro_ciudadano(data: RegistroUsuario) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT id_usuario FROM usuarios WHERE correo = %s;",
                (data.correo,)
            )
            if cursor.fetchone():
                raise HTTPException(
                    status_code=400,
                    detail="El correo ya está registrado"
                )

            if data.numero_documento:
                cursor.execute(
                    "SELECT id_usuario FROM usuarios WHERE numero_documento = %s;",
                    (data.numero_documento,)
                )
                if cursor.fetchone():
                    raise HTTPException(
                        status_code=400,
                        detail="El número de documento ya está registrado"
                    )

            password_hash = hash_password(data.password)

            cursor.execute("""
                INSERT INTO usuarios
                    (id_rol, id_estado_cuenta, nombre_completo, correo, password_hash,
                     fecha_nacimiento, tipo_documento, numero_documento,
                     telefono, pais, ciudad, direccion)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
            """, (
                1, 4,
                data.nombre_completo, data.correo, password_hash,
                data.fecha_nacimiento, data.tipo_documento, data.numero_documento,
                data.telefono, data.pais, data.ciudad, data.direccion
            ))
            nuevo_id = cursor.lastrowid

        return {
            "message": "Usuario registrado exitosamente. Su cuenta está pendiente de activación.",
            "id_usuario": nuevo_id,
            "estado": "PENDIENTE",
            "instruccion": "Un administrador debe activar tu cuenta antes de que puedas iniciar sesión."
        }
    except HTTPException:
        raise
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


# =========================
# RECUPERACIÓN DE CONTRASEÑA
# =========================

@router.post(
    "/solicitar-recuperacion",
    summary="Solicitar token para restablecer contraseña (sin token)"
)
def solicitar_recuperacion(data: SolicitarRecuperacion) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT id_usuario FROM usuarios WHERE correo = %s;",
                (data.correo,)
            )
            usuario = cursor.fetchone()

            if not usuario:
                return {
                    "message": "Si el correo existe, recibirás las instrucciones de recuperación."
                }

            token = secrets.token_urlsafe(32)
            expiracion = datetime.now() + timedelta(hours=2)

            cursor.execute("""
                INSERT INTO recuperacion_contrasena
                    (id_usuario, token, fecha_expiracion, usado)
                VALUES (%s, %s, %s, 0);
            """, (usuario["id_usuario"], token, expiracion))

        return {
            "message": "Token generado exitosamente",
            "token": token,
            "expira_en": "2 horas"
        }
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


@router.post(
    "/restablecer-contrasena",
    summary="Restablecer contraseña usando el token recibido (sin token)"
)
def restablecer_contrasena(data: RestablecerContrasena) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT id_recuperacion, id_usuario, fecha_expiracion, usado
                FROM recuperacion_contrasena
                WHERE token = %s;
            """, (data.token,))
            registro = cursor.fetchone()

            if not registro:
                raise HTTPException(status_code=400, detail="Token inválido")
            if registro["usado"]:
                raise HTTPException(status_code=400, detail="El token ya fue utilizado")
            if datetime.now() > registro["fecha_expiracion"]:
                raise HTTPException(status_code=400, detail="El token ha expirado")

            nuevo_hash = hash_password(data.nueva_password)

            cursor.execute(
                "UPDATE usuarios SET password_hash = %s, updated_at = NOW() WHERE id_usuario = %s;",
                (nuevo_hash, registro["id_usuario"])
            )
            cursor.execute(
                "UPDATE recuperacion_contrasena SET usado = 1 WHERE id_recuperacion = %s;",
                (registro["id_recuperacion"],)
            )

        return {"message": "Contraseña restablecida exitosamente. Ya puedes iniciar sesión."}
    except HTTPException:
        raise
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


# =========================
# PERFIL PROPIO
# =========================

@router.get(
    "/perfil",
    summary="Ver mi perfil (usuario autenticado)"
)
def ver_perfil(
    user: Dict[str, Any] = Depends(require_active_user)
) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT
                    u.id_usuario, u.nombre_completo, u.correo,
                    u.telefono, u.pais, u.ciudad, u.direccion,
                    u.tipo_documento, u.numero_documento,
                    u.fecha_nacimiento,
                    r.nombre  AS rol,
                    ec.nombre AS estado_cuenta,
                    u.created_at, u.updated_at
                FROM usuarios u
                JOIN roles         r  ON r.id_rol            = u.id_rol
                JOIN estado_cuenta ec ON ec.id_estado_cuenta = u.id_estado_cuenta
                WHERE u.id_usuario = %s;
            """, (user["id_usuario"],))
            return cursor.fetchone()
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


@router.put(
    "/perfil",
    summary="Actualizar mi perfil (usuario autenticado)"
)
def actualizar_perfil(
    data: ActualizarPerfil,
    user: Dict[str, Any] = Depends(require_active_user)
) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            campos = {k: v for k, v in data.model_dump().items() if v is not None}
            if not campos:
                raise HTTPException(
                    status_code=400,
                    detail="No se enviaron campos para actualizar"
                )

            set_clause = ", ".join([f"{k} = %s" for k in campos])
            valores = list(campos.values()) + [user["id_usuario"]]

            cursor.execute(
                f"UPDATE usuarios SET {set_clause}, updated_at = NOW() WHERE id_usuario = %s;",
                valores
            )
        return {"message": "Perfil actualizado exitosamente"}
    except HTTPException:
        raise
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


# =========================
# ADMINISTRACIÓN (SOLO ADMIN)
# =========================

# ✅ IMPORTANTE: /pendientes ANTES de /{id_usuario}
@router.get(
    "/pendientes",
    summary="Listar usuarios pendientes de activación (solo ADMIN)"
)
def listar_pendientes(
    user: Dict[str, Any] = Depends(require_roles(4))
) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT
                    u.id_usuario, u.nombre_completo, u.correo,
                    u.telefono, u.ciudad,
                    u.tipo_documento, u.numero_documento,
                    u.created_at
                FROM usuarios u
                WHERE u.id_estado_cuenta = 4
                ORDER BY u.created_at ASC;
            """)
            pendientes = cursor.fetchall()
        return {
            "total_pendientes": len(pendientes),
            "usuarios": pendientes
        }
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


@router.get(
    "/",
    summary="Listar todos los usuarios (solo ADMIN)"
)
def listar_usuarios(
    user: Dict[str, Any] = Depends(require_roles(4))
) -> List[Dict[str, Any]]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT
                    u.id_usuario, u.nombre_completo, u.correo,
                    u.telefono, u.ciudad,
                    r.nombre  AS rol,
                    ec.nombre AS estado_cuenta,
                    u.created_at
                FROM usuarios u
                JOIN roles         r  ON r.id_rol            = u.id_rol
                JOIN estado_cuenta ec ON ec.id_estado_cuenta = u.id_estado_cuenta
                ORDER BY u.created_at DESC;
            """)
            return cursor.fetchall()
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


# ✅ RUTAS CON PARÁMETRO DINÁMICO SIEMPRE AL FINAL
@router.get(
    "/{id_usuario}",
    summary="Ver detalle de un usuario (solo ADMIN)"
)
def detalle_usuario(
    id_usuario: int,
    user: Dict[str, Any] = Depends(require_roles(4))
) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT
                    u.id_usuario, u.nombre_completo, u.correo,
                    u.telefono, u.pais, u.ciudad, u.direccion,
                    u.tipo_documento, u.numero_documento,
                    u.fecha_nacimiento,
                    r.nombre  AS rol,
                    ec.nombre AS estado_cuenta,
                    u.id_entidad,
                    u.created_at, u.updated_at
                FROM usuarios u
                JOIN roles         r  ON r.id_rol            = u.id_rol
                JOIN estado_cuenta ec ON ec.id_estado_cuenta = u.id_estado_cuenta
                WHERE u.id_usuario = %s;
            """, (id_usuario,))
            registro = cursor.fetchone()
            if not registro:
                raise HTTPException(status_code=404, detail="Usuario no encontrado")
            return registro
    except HTTPException:
        raise
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()


@router.put(
    "/{id_usuario}/estado",
    summary="Activar / suspender / desactivar un usuario (solo ADMIN)"
)
def cambiar_estado_usuario(
    id_usuario: int,
    data: CambiarEstadoCuenta,
    user: Dict[str, Any] = Depends(require_roles(4))
) -> Dict[str, Any]:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT id_usuario, nombre_completo FROM usuarios WHERE id_usuario = %s;",
                (id_usuario,)
            )
            usuario = cursor.fetchone()
            if not usuario:
                raise HTTPException(status_code=404, detail="Usuario no encontrado")

            cursor.execute(
                "SELECT id_estado_cuenta, nombre FROM estado_cuenta WHERE id_estado_cuenta = %s;",
                (data.id_estado_cuenta,)
            )
            estado = cursor.fetchone()
            if not estado:
                raise HTTPException(status_code=400, detail="Estado de cuenta inválido")

            cursor.execute(
                "UPDATE usuarios SET id_estado_cuenta = %s, updated_at = NOW() WHERE id_usuario = %s;",
                (data.id_estado_cuenta, id_usuario)
            )

        return {
            "message": "Estado de cuenta actualizado exitosamente",
            "usuario": usuario["nombre_completo"],
            "nuevo_estado": estado["nombre"]
        }
    except HTTPException:
        raise
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")
    finally:
        conn.close()
