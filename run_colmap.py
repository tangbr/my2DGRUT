import cv2
import os

video_path = "/app/video/my_video.mp4"
output_dir = "/app/images"
os.makedirs(output_dir, exist_ok=True)

frame_interval = 10  # every 10 frames
count = 0
saved = 0

vidcap = cv2.VideoCapture(video_path)
success, image = vidcap.read()

if not success:
    print(" Failed to open video.")
else:
    while success:
        if count % frame_interval == 0:
            frame_path = os.path.join(output_dir, f"frame_{saved:04d}.jpg")
            cv2.imwrite(frame_path, image)
            saved += 1
        success, image = vidcap.read()
        count += 1

    print(f" {saved} frames saved (out of {count} total frames)")
