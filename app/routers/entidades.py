from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
from app.db.database import get_connection
from app.core.deps import require_roles
import pymysql

router = APIRouter(prefix="/entidades", tags=["Entidades"])


# ─── Modelos ────────────────────────────────────────────────────────────────

class CrearEntidad(BaseModel):
    nombre_entidad: str
    nit_rut: str
    correo_institucional: str
    telefono: Optional[str] = None
    direccion: Optional[str] = None
    funcionario_responsable: Optional[str] = None
    documento_funcionario: Optional[str] = None
    sitio_web: Optional[str] = None


class ActualizarEntidad(BaseModel):
    nombre_entidad: Optional[str] = None
    correo_institucional: Optional[str] = None
    telefono: Optional[str] = None
    direccion: Optional[str] = None
    funcionario_responsable: Optional[str] = None
    documento_funcionario: Optional[str] = None
    sitio_web: Optional[str] = None


class CambiarEstadoEntidad(BaseModel):
    id_estado_cuenta: int


# ─── Endpoints ──────────────────────────────────────────────────────────────

@router.get("/", summary="Listar todas las entidades")
def listar_entidades():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT e.id_entidad, e.nombre_entidad, e.nit_rut,
                       e.correo_institucional, e.telefono, e.direccion,
                       e.funcionario_responsable, e.documento_funcionario,
                       e.sitio_web, ec.nombre AS estado, e.created_at
                FROM entidades e
                JOIN estado_cuenta ec ON ec.id_estado_cuenta = e.id_estado_cuenta
                ORDER BY e.id_entidad
            """)
            entidades = cursor.fetchall()
        return {"total": len(entidades), "entidades": entidades}
    finally:
        conn.close()


@router.get("/{id_entidad}", summary="Obtener detalle de una entidad")
def obtener_entidad(id_entidad: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT e.id_entidad, e.nombre_entidad, e.nit_rut,
                       e.correo_institucional, e.telefono, e.direccion,
                       e.funcionario_responsable, e.documento_funcionario,
                       e.sitio_web, ec.nombre AS estado,
                       e.created_at, e.updated_at
                FROM entidades e
                JOIN estado_cuenta ec ON ec.id_estado_cuenta = e.id_estado_cuenta
                WHERE e.id_entidad = %s
            """, (id_entidad,))
            entidad = cursor.fetchone()
        if not entidad:
            raise HTTPException(status_code=404, detail="Entidad no encontrada")
        return entidad
    finally:
        conn.close()


@router.post("/", status_code=201, summary="Crear nueva entidad (solo ADMIN)")
def crear_entidad(
    datos: CrearEntidad,
    current_user: dict = Depends(require_roles(4))
):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO entidades (
                    id_estado_cuenta, nombre_entidad, nit_rut,
                    correo_institucional, telefono, direccion,
                    funcionario_responsable, documento_funcionario, sitio_web
                ) VALUES (1, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                datos.nombre_entidad, datos.nit_rut,
                datos.correo_institucional, datos.telefono,
                datos.direccion, datos.funcionario_responsable,
                datos.documento_funcionario, datos.sitio_web
            ))
            conn.commit()
            nuevo_id = cursor.lastrowid
        return {"message": "Entidad creada exitosamente", "id_entidad": nuevo_id}
    except pymysql.err.IntegrityError:
        raise HTTPException(status_code=400, detail="El NIT/RUT o correo ya está registrado")
    finally:
        conn.close()


@router.put("/{id_entidad}", summary="Actualizar entidad (solo ADMIN)")
def actualizar_entidad(
    id_entidad: int,
    datos: ActualizarEntidad,
    current_user: dict = Depends(require_roles(4))
):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id_entidad FROM entidades WHERE id_entidad = %s", (id_entidad,))
            if not cursor.fetchone():
                raise HTTPException(status_code=404, detail="Entidad no encontrada")

            campos = []
            valores = []
            if datos.nombre_entidad:
                campos.append("nombre_entidad = %s"); valores.append(datos.nombre_entidad)
            if datos.correo_institucional:
                campos.append("correo_institucional = %s"); valores.append(datos.correo_institucional)
            if datos.telefono:
                campos.append("telefono = %s"); valores.append(datos.telefono)
            if datos.direccion:
                campos.append("direccion = %s"); valores.append(datos.direccion)
            if datos.funcionario_responsable:
                campos.append("funcionario_responsable = %s"); valores.append(datos.funcionario_responsable)
            if datos.documento_funcionario:
                campos.append("documento_funcionario = %s"); valores.append(datos.documento_funcionario)
            if datos.sitio_web:
                campos.append("sitio_web = %s"); valores.append(datos.sitio_web)

            if not campos:
                raise HTTPException(status_code=400, detail="No hay campos para actualizar")

            valores.append(id_entidad)
            cursor.execute(
                f"UPDATE entidades SET {', '.join(campos)}, updated_at = NOW() WHERE id_entidad = %s",
                valores
            )
            conn.commit()
        return {"message": "Entidad actualizada exitosamente"}
    finally:
        conn.close()


@router.put("/{id_entidad}/estado", summary="Cambiar estado de entidad (solo ADMIN)")
def cambiar_estado_entidad(
    id_entidad: int,
    payload: CambiarEstadoEntidad,
    current_user: dict = Depends(require_roles(4))
):
    if payload.id_estado_cuenta not in [1, 2, 3, 4]:
        raise HTTPException(status_code=400, detail="Estado inválido")

    estados = {1: "ACTIVO", 2: "INACTIVO", 3: "SUSPENDIDO", 4: "PENDIENTE"}
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT nombre_entidad FROM entidades WHERE id_entidad = %s", (id_entidad,))
            entidad = cursor.fetchone()
            if not entidad:
                raise HTTPException(status_code=404, detail="Entidad no encontrada")
            cursor.execute(
                "UPDATE entidades SET id_estado_cuenta = %s, updated_at = NOW() WHERE id_entidad = %s",
                (payload.id_estado_cuenta, id_entidad)
            )
            conn.commit()
        return {
            "message": "Estado actualizado exitosamente",
            "entidad": entidad["nombre_entidad"],
            "nuevo_estado": estados[payload.id_estado_cuenta]
        }
    finally:
        conn.close()
