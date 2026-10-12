import cv2
import time
from ultralytics import YOLO

# ---------- CONFIGURACIÓN ----------
URL = "http://192.168.1.XX:8080/videofeed"  # cambie XX por la IP de su celular

MODELO = "yolov8n.pt"      # cuando tengan su modelo de Roboflow: "best.pt"
CLASES = {0: "Persona", 14: "Pollo"}        # "bird" de YOLO = pollo/ave
CONFIANZA = {"Persona": 0.5, "Pollo": 0.2}  # los pollos se detectan con menos seguridad
CONF_MODELO = 0.2
TAMANO_IMG = 640           # sube a 960 si los pollos se ven pequeños
COOLDOWN = 10              # segundos mínimos entre alertas
# -----------------------------------

model = YOLO(MODELO)
ultima_alerta = 0

cap = cv2.VideoCapture(URL)
cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

while True:
    ok, frame = cap.read()
    if not ok:
        print("No se pudo leer el video: revise IP y Wi-Fi")
        break

    resultados = model(frame, verbose=False, conf=CONF_MODELO,
                       imgsz=TAMANO_IMG)[0]

    for box in resultados.boxes:
        clase = int(box.cls[0])
        conf = float(box.conf[0])
        tipo = CLASES.get(clase)
        if tipo and conf >= CONFIANZA[tipo] and time.time() - ultima_alerta > COOLDOWN:
            ultima_alerta = time.time()
            print(f"ALERTA: {tipo} detectado ({conf:.0%})")
            # Aquí conectaremos Firebase en el siguiente paso

    cv2.imshow("Prototipo Bioseguridad ULEAM", resultados.plot())
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()