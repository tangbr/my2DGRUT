import cv2
import os
import argparse
from tqdm import tqdm
import sys

def extract_frames(video_path, output_dir, step=10):
    if not os.path.isfile(video_path):
        print(f"❌ Video file does not exist: {video_path}")
        sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        raise IOError(f"❌ Cannot open video: {video_path}")

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    frame_count, saved_count = 0, 0

    print(f"🎞️  Starting frame extraction from: {video_path}")
    print(f"📂 Saving every {step} frame(s) to: {output_dir}")

    with tqdm(total=total_frames, desc="Extracting frames") as pbar:
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            if frame_count % step == 0:
                filename = os.path.join(output_dir, f"frame_{saved_count:04d}.jpg")
                cv2.imwrite(filename, frame)
                saved_count += 1
            frame_count += 1
            pbar.update(1)

    cap.release()
    print(f"✅ Done: {saved_count} frames saved (from {frame_count} total) to {output_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract frames from video at regular intervals.")
    parser.add_argument("--video", required=True, help="Path to input video")
    parser.add_argument("--out", default="./images", help="Output directory for images")
    parser.add_argument("--step", type=int, default=10, help="Frame interval for extraction")
    args = parser.parse_args()

    extract_frames(args.video, args.out, args.step)
