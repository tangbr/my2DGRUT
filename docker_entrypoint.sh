#!/bin/bash
set -e

VIDEO_PATH="$1"
USERNAME="$2"

if [[ -z "$VIDEO_PATH" || -z "$USERNAME" ]]; then
    echo "❌ Usage: docker run ... /path/to/video username"
    exit 1
fi

echo "🔹 User: $USERNAME"
echo "🎞️  Extracting frames from video: $VIDEO_PATH"

python3 /app/extract_frames.py \
    --video "$VIDEO_PATH" \
    --out /app/images \
    --step 10

echo "📸 Frames extracted to /app/images"

echo "🧠 Running COLMAP reconstruction..."
python3 /app/run_colmap.py \
    --images /app/images \
    --out /app/output

if [[ -f /app/output/model.ply ]]; then
    echo "✅ Reconstruction completed for user: $USERNAME"
    echo "🎯 Output PLY model: /app/output/model.ply"
else
    echo "❌ Reconstruction failed or model.ply not found"
    exit 2
fi

# Optional visualization:
# meshlab /app/output/model.ply
