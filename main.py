from fastapi import FastAPI
# app = FastAPI(...) → crea tu aplicación backend.
app = FastAPI(title="Geovisor API")
@app.get("/")
def root():
    return {"message": "Geovisor API running"}

# @app.get("/health") → crea una ruta (endpoint) de prueba.
@app.get("/health")
def health():
    return {"status": "ok"}
