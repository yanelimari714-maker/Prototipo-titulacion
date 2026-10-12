import cv2

URL = "http://192.168.1.2:8080/videofeed"  # cambie por su IP
cap = cv2.VideoCapture(URL)

while True:
    ok, frame = cap.read()
    if not ok:
        print("No se pudo leer el video: revise IP y Wi-Fi")
        break
        
    cv2.imshow("Prueba", frame)
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()