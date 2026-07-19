from typing import Optional, Any, Dict, List
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from pymysql.err import IntegrityError, ProgrammingError, OperationalError

from app.db.database import get_connection
from app.core.deps import require_active_user

router = APIRouter(prefix="/reportes", tags=["reportes"])

# Roles según tu tabla roles:
ROLE_CIUDADANO = 1
ROLE_ENTIDAD   = 2
ROLE_MODERADOR = 3
ROLE_ADMIN     = 4

# Estado cuenta según tu tabla estado_cuenta:
ESTADO_CUENTA_ACTIVO = 1


# =========================
# MODELOS
# =========================

class ReporteCreateRequest(BaseModel):
    id_usuario: Optional[int] = Field(
        None, ge=1,
        description="(Opcional) debe coincidir con el usuario del token. Recomendado: NO enviarlo."
    )
    id_tipo_incidente: int  = Field(..., ge=1)
    id_severidad:      int  = Field(..., ge=1)
    descripcion:       str  = Field(..., min_length=1, max_length=5000)
    direccion:  Optional[str]   = Field(None, max_length=255)
    latitud:    Optional[float] = None
    longitud:   Optional[float] = None
    imagen_url: Optional[str]   = Field(None, max_length=500)
    fuente_reporte: str = Field("CIUDADANO", max_length=50)


class CambiarEstadoRequest(BaseModel):
    id_estado_nuevo:    int           = Field(..., ge=1)
    comentario: Optional[str]         = Field(None, max_length=500)


# =========================
# HELPERS
# =========================

def _raise_db_error(e: Exception):
    if isinstance(e, ProgrammingError):
        raise HTTPException(status_code=500, detail=f"DB error (SQL): {e}")
    if isinstance(e, IntegrityError):
        raise HTTPException(
            status_code=400,
            detail=(
                f"DB error (Integridad/FK): {e}. "
                "Verifica que los IDs existan. No uses 0."
            ),
        )
    if isinstance(e, OperationalError):
        raise HTTPException(status_code=500, detail=f"DB error (Conexión): {e}")
    raise HTTPException(status_code=500, detail=f"DB error: {e}")


def _get_usuario_entidad(cursor, id_usuario: int) -> Optional[int]:
    cursor.execute("SELECT id_entidad FROM usuarios WHERE id_usuario = %s;", (id_usuario,))
    row = cursor.fetchone()
    if not row:
        raise HTTPException(status_code=400, detail="id_usuario no existe en la tabla usuarios")
    return row.get("id_entidad")


def _select_reporte_detalle_sql() -> str:
    return """
    SELECT
      r.id_reporte,
      r.descripcion,
      r.direccion,
      r.latitud,
      r.longitud,
      r.imagen_url,
      r.fuente_reporte,
      r.created_at,
      r.id_usuario,
      r.id_entidad,
      r.id_tipo_incidente,
      r.id_severidad,
      r.id_estado,
      u.nombre_completo AS usuario,
      er.nombre         AS estado,
      ti.nombre         AS tipo_incidente,
      s.nombre          AS severidad
    FROM reportes r
    JOIN usuarios      u  ON r.id_usuario        = u.id_usuario
    JOIN estado_reporte er ON r.id_estado         = er.id_estado
    JOIN tipo_incidente ti ON r.id_tipo_incidente = ti.id_tipo_incidente
    JOIN severidad      s  ON r.id_severidad      = s.id_severidad
    """


def _insertar_historial(cursor, id_reporte: int, estado_anterior: str,
                        estado_nuevo: str, id_usuario_accion: int,
                        comentario: Optional[str] = None):
    cursor.execute("""
        INSERT INTO historial_reportes
            (id_reporte, estado_anterior, estado_nuevo, comentario, id_usuario_accion, fecha_cambio)
        VALUES (%s, %s, %s, %s, %s, NOW());
    """, (id_reporte, estado_anterior, estado_nuevo, comentario, id_usuario_accion))


def _insertar_notificacion(cursor, id_usuario: int, id_reporte: int,
                           tipo: str, mensaje: str):
    cursor.execute("""
        INSERT INTO notificaciones
            (id_usuario, id_reporte, tipo_notificacion, mensaje, leida, fecha_envio)
        VALUES (%s, %s, %s, %s, 0, NOW());
    """, (id_usuario, id_reporte, tipo, mensaje))


# =========================
# ENDPOINTS
# =========================

# ✅ PRIMERO el endpoint /mapa (público, sin token)
@router.get("/mapa", summary="Obtener reportes para el mapa (público)")
def reportes_para_mapa():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT
                    r.id_reporte,
                    r.latitud,
                    r.longitud,
                    r.descripcion,
                    r.direccion,
                    ti.nombre AS tipo_incidente,
                    s.nombre  AS severidad,
                    er.nombre AS estado,
                    r.fecha_reporte
                FROM reportes r
                JOIN tipo_incidente ti ON ti.id_tipo_incidente = r.id_tipo_incidente
                JOIN severidad s       ON s.id_severidad       = r.id_severidad
                JOIN estado_reporte er ON er.id_estado         = r.id_estado
                WHERE r.latitud  != 0.0
                  AND r.longitud != 0.0
                ORDER BY r.fecha_reporte DESC
            """)
            puntos = cursor.fetchall()
        return {
            "total": len(puntos),
            "puntos": puntos
        }
    finally:
        conn.close()


@router.get("/", summary="Listar Reportes")
def listar_reportes(
    user: Dict[str, Any] = Depends(require_active_user)
) -> List[Dict[str, Any]]:

    conn = get_connection()
    try:
        base_sql = _select_reporte_detalle_sql()
        params   = []

        if user["id_rol"] == ROLE_CIUDADANO:
            base_sql += " WHERE r.id_usuario = %s "
            params.append(user["id_usuario"])
        elif user["id_rol"] == ROLE_ENTIDAD:
            if not user.get("id_entidad"):
                raise HTTPException(status_code=403, detail="Usuario ENTIDAD sin id_entidad asignado")
            base_sql += " WHERE r.id_entidad = %s "
            params.append(user["id_entidad"])
        elif user["id_rol"] in (ROLE_MODERADOR, ROLE_ADMIN):
            pass
        else:
            raise HTTPException(status_code=403, detail="Rol desconocido")

        sql = base_sql + " ORDER BY r.created_at DESC;"
        with conn.cursor() as cursor:
            cursor.execute(sql, params)
            return cursor.fetchall()

    except HTTPException:
        raise
    except Exception as e:
        _raise_db_error(e)
    finally:
        conn.close()


@router.get("/{id_reporte}", summary="Obtener Reporte")
def obtener_reporte(
    id_reporte: int,
    user: Dict[str, Any] = Depends(require_active_user)
) -> Dict[str, Any]:

    conn = get_connection()
    try:
        sql = _select_reporte_detalle_sql() + " WHERE r.id_reporte = %s;"
        with conn.cursor() as cursor:
            cursor.execute(sql, (id_reporte,))
            row = cursor.fetchone()

        if not row:
            raise HTTPException(status_code=404, detail="Reporte no encontrado")

        if user["id_rol"] == ROLE_CIUDADANO and row["id_usuario"] != user["id_usuario"]:
            raise HTTPException(status_code=403, detail="No puedes ver reportes de otros usuarios")
        if user["id_rol"] == ROLE_ENTIDAD and row["id_entidad"] != user.get("id_entidad"):
            raise HTTPException(status_code=403, detail="No puedes ver reportes de otra entidad")

        return row

    except HTTPException:
        raise
    except Exception as e:
        _raise_db_error(e)
    finally:
        conn.close()


@router.post("/", summary="Crear Reporte")
def crear_reporte(
    payload: ReporteCreateRequest,
    user:    Dict[str, Any] = Depends(require_active_user),
) -> Dict[str, Any]:

    if user.get("id_estado_cuenta") != ESTADO_CUENTA_ACTIVO:
        raise HTTPException(status_code=403, detail="Tu cuenta no está ACTIVA")
    if user.get("id_rol") not in (ROLE_CIUDADANO, ROLE_ENTIDAD):
        raise HTTPException(status_code=403, detail="No tienes permisos para crear reportes")

    id_usuario_token = user["id_usuario"]

    if payload.id_usuario is not None and payload.id_usuario != id_usuario_token:
        raise HTTPException(status_code=403, detail="No puedes crear reportes a nombre de otro usuario")

    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            id_entidad = _get_usuario_entidad(cursor, id_usuario_token)

            if user["id_rol"] == ROLE_ENTIDAD and not id_entidad:
                raise HTTPException(status_code=403, detail="Usuario ENTIDAD sin id_entidad asignado")

            id_estado_inicial = 1
            fuente = "CIUDADANO" if user["id_rol"] == ROLE_CIUDADANO else "ENTIDAD"

            cursor.execute("""
                INSERT INTO reportes (
                    id_usuario, id_entidad, id_tipo_incidente, id_severidad, id_estado,
                    descripcion, direccion, latitud, longitud, imagen_url, fuente_reporte
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
            """, (
                id_usuario_token, id_entidad,
                payload.id_tipo_incidente, payload.id_severidad, id_estado_inicial,
                payload.descripcion, payload.direccion,
                payload.latitud, payload.longitud,
                payload.imagen_url, fuente,
            ))
            new_id = cursor.lastrowid

            _insertar_historial(
                cursor,
                id_reporte        = new_id,
                estado_anterior   = "NINGUNO",
                estado_nuevo      = "PENDIENTE",
                id_usuario_accion = id_usuario_token,
                comentario        = "Reporte creado por el usuario"
            )

            _insertar_notificacion(
                cursor,
                id_usuario = id_usuario_token,
                id_reporte = new_id,
                tipo       = "REPORTE_CREADO",
                mensaje    = "Tu reporte fue creado exitosamente y está en estado PENDIENTE"
            )

            sql = _select_reporte_detalle_sql() + " WHERE r.id_reporte = %s;"
            cursor.execute(sql, (new_id,))
            row = cursor.fetchone()

        return {"message": "created", "reporte": row}

    except HTTPException:
        raise
    except Exception as e:
        _raise_db_error(e)
    finally:
        conn.close()


@router.put("/{id_reporte}/estado", summary="Cambiar Estado")
def cambiar_estado(
    id_reporte: int,
    payload:    CambiarEstadoRequest,
    user:       Dict[str, Any] = Depends(require_active_user),
) -> Dict[str, Any]:

    if user["id_rol"] == ROLE_CIUDADANO:
        raise HTTPException(status_code=403, detail="No tienes permisos para cambiar el estado")

    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT r.id_reporte, r.id_entidad, r.id_usuario,
                       er.nombre AS estado_actual
                FROM reportes r
                JOIN estado_reporte er ON r.id_estado = er.id_estado
                WHERE r.id_reporte = %s;
            """, (id_reporte,))
            rep = cursor.fetchone()
            if not rep:
                raise HTTPException(status_code=404, detail="Reporte no encontrado")

            if user["id_rol"] == ROLE_ENTIDAD:
                if not user.get("id_entidad"):
                    raise HTTPException(status_code=403, detail="Usuario ENTIDAD sin id_entidad asignado")
                if rep.get("id_entidad") != user["id_entidad"]:
                    raise HTTPException(status_code=403, detail="No puedes modificar reportes de otra entidad")

            cursor.execute(
                "SELECT nombre FROM estado_reporte WHERE id_estado = %s;",
                (payload.id_estado_nuevo,)
            )
            nuevo_estado_row = cursor.fetchone()
            if not nuevo_estado_row:
                raise HTTPException(status_code=400, detail="id_estado_nuevo no existe")
            nombre_estado_nuevo = nuevo_estado_row["nombre"]

            cursor.execute(
                "UPDATE reportes SET id_estado = %s, updated_at = NOW() WHERE id_reporte = %s;",
                (payload.id_estado_nuevo, id_reporte),
            )

            _insertar_historial(
                cursor,
                id_reporte        = id_reporte,
                estado_anterior   = rep["estado_actual"],
                estado_nuevo      = nombre_estado_nuevo,
                id_usuario_accion = user["id_usuario"],
                comentario        = payload.comentario
            )

            _insertar_notificacion(
                cursor,
                id_usuario = rep["id_usuario"],
                id_reporte = id_reporte,
                tipo       = "CAMBIO_ESTADO",
                mensaje    = f"Tu reporte cambió a {nombre_estado_nuevo}"
            )

            sql = _select_reporte_detalle_sql() + " WHERE r.id_reporte = %s;"
            cursor.execute(sql, (id_reporte,))
            row = cursor.fetchone()

        return {"message": "updated", "reporte": row}

    except HTTPException:
        raise
    except Exception as e:
        _raise_db_error(e)
    finally:
        conn.close()
