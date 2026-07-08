from ultralytics import YOLO
import cv2

# مدل سبک برای گوشی
model = YOLO("yolov8n.pt")

# آدرس استریم IP Webcam
STREAM_URL = "http://192.168.43.1:8080/video"

cap = cv2.VideoCapture(STREAM_URL)

if not cap.isOpened():
    print("Cannot open stream")
    exit()

while True:

    ret, frame = cap.read()

    if not ret:
        continue

    # اجرای YOLO روی فریم
    results = model(frame, verbose=False)

    # رسم نتایج روی تصویر
    annotated_frame = results[0].plot()

    # بررسی وجود انسان
    person_found = False

    for box in results[0].boxes:
        cls = int(box.cls[0])
        if model.names[cls] == "person":
            person_found = True
            break

    if person_found:
        print("🚨 PERSON DETECTED")

    # نمایش تصویر
    cv2.imshow("Live Stream Detection", annotated_frame)

    # خروج با ESC
    if cv2.waitKey(1) == 27:
        break

cap.release()
cv2.destroyAllWindows()