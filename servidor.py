import os
import uuid
import shutil
import threading
import time
import cv2
import numpy as np
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, StreamingResponse
from ultralytics import YOLO

os.makedirs("evidencias", exist_ok=True)
os.makedirs("subidas", exist_ok=True)

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"],
                   allow_methods=["*"], allow_headers=["*"])
app.mount("/evidencias", StaticFiles(directory="evidencias"), name="evidencias")

# ---------- CONFIGURACIÓN ----------
MODELO = "yolov8n.pt"        # cuando tengan su modelo de Roboflow: "best.pt"
CLASES = {0: "Persona", 14: "Pollo"}   # "bird" de YOLO = pollo/ave
# Confianza mínima por tipo: los pollos se detectan con menos seguridad
CONFIANZA = {"Persona": 0.5, "Pollo": 0.2}
CONF_MODELO = 0.2            # umbral general que usa el modelo (el menor de arriba)
TAMANO_IMG = 640             # sube a 960 si los pollos se ven pequeños (más lento)
SEGUNDOS_ENTRE_ALERTAS = 2   # subir video: no repetir el mismo tipo antes de 2 s
SALTO = 3                    # subir video: analiza 1 de cada 3 cuadros
COOLDOWN_VIVO = 5            # cámara: segundos entre alertas del mismo tipo
DEPURAR = True               # muestra en la terminal TODO lo que ve la IA
# -----------------------------------

model = YOLO(MODELO)
candado = threading.Lock()   # el modelo no se puede usar en dos hilos a la vez
alertas_vivo = []            # últimas alertas de la cámara en vivo


def detectar(frame):
    """Corre YOLO sobre un cuadro. Devuelve (resultado, {tipo: confianza})."""
    with candado:
        resultado = model(frame, verbose=False, conf=CONF_MODELO,
                          imgsz=TAMANO_IMG)[0]
    encontrados = {}
    for box in resultado.boxes:
        clase = int(box.cls[0])
        conf = float(box.conf[0])
        tipo = CLASES.get(clase)
        if tipo and conf >= CONFIANZA[tipo]:
            encontrados[tipo] = max(conf, encontrados.get(tipo, 0))
    return resultado, encontrados


@app.get("/")
def inicio():
    return FileResponse("index.html")


# ---------- SUBIR VIDEO ----------
@app.post("/analizar")
def analizar(video: UploadFile = File(...)):
    ruta = f"subidas/{uuid.uuid4().hex}_{video.filename}"
    with open(ruta, "wb") as f:
        shutil.copyfileobj(video.file, f)

    cap = cv2.VideoCapture(ruta)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30
    detecciones = []
    ultimo = {}   # último segundo en que se alertó cada tipo
    n = -1

    while True:
        ok, frame = cap.read()
        if not ok:
            break
        n += 1
        if n % SALTO:
            continue

        segundo = n / fps
        resultado, encontrados = detectar(frame)

        for tipo, conf in encontrados.items():
            if segundo - ultimo.get(tipo, -999) >= SEGUNDOS_ENTRE_ALERTAS:
                ultimo[tipo] = segundo
                nombre = f"{uuid.uuid4().hex}.jpg"
                cv2.imwrite(f"evidencias/{nombre}", resultado.plot())
                detecciones.append({
                    "tiempo": round(segundo, 1),
                    "tipo": tipo,
                    "confianza": round(conf * 100),
                    "imagen": f"/evidencias/{nombre}",
                })

    cap.release()
    os.remove(ruta)

    resumen = {}
    for d in detecciones:
        resumen[d["tipo"]] = resumen.get(d["tipo"], 0) + 1
    return {"resumen": resumen, "detecciones": detecciones}


# ---------- CÁMARA EN VIVO ----------
def generar_stream(url):
    print(f"[CAMARA] Conectando a {url}")
    cap = cv2.VideoCapture(url)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    ultimo = {}
    ultimo_debug = 0

    if not cap.isOpened():
        print("[CAMARA] ERROR: no se pudo abrir la URL")
        cap.release()
        img = np.zeros((360, 640, 3), dtype=np.uint8)
        cv2.putText(img, "No se pudo abrir la camara", (40, 180),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
        _, buf = cv2.imencode(".jpg", img)
        yield (b"--frame\r\nContent-Type: image/jpeg\r\n\r\n"
               + buf.tobytes() + b"\r\n")
        return

    print("[CAMARA] Conectada. Procesando video...")
    try:
        while True:
            ok, frame = cap.read()
            if not ok:
                print("[CAMARA] Se perdió el video")
                break

            resultado, encontrados = detectar(frame)

            # Depuración: qué está viendo la IA (1 vez por segundo)
            if DEPURAR and time.time() - ultimo_debug > 1:
                ultimo_debug = time.time()
                vistos = [f"{model.names[int(b.cls[0])]} {float(b.conf[0]):.0%}"
                          for b in resultado.boxes]
                print("[VE]", ", ".join(vistos) if vistos else "nada")

            for tipo, conf in encontrados.items():
                if time.time() - ultimo.get(tipo, 0) > COOLDOWN_VIVO:
                    ultimo[tipo] = time.time()
                    alertas_vivo.append({
                        "hora": time.strftime("%H:%M:%S"),
                        "tipo": tipo,
                        "confianza": round(conf * 100),
                    })
                    del alertas_vivo[:-30]
                    print(f"[ALERTA] {tipo} ({conf:.0%})")
                    # Aquí conectaremos Firebase

            ok2, buf = cv2.imencode(".jpg", resultado.plot())
            if ok2:
                yield (b"--frame\r\nContent-Type: image/jpeg\r\n\r\n"
                       + buf.tobytes() + b"\r\n")
    finally:
        cap.release()
        print("[CAMARA] Cerrada")


@app.get("/camara/video")
def camara_video(url: str):
    return StreamingResponse(
        generar_stream(url),
        media_type="multipart/x-mixed-replace; boundary=frame")


@app.get("/camara/alertas")
def camara_alertas():
    return list(reversed(alertas_vivo))