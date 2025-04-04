import subprocess
import argparse
import os
import sys

def run_colmap(image_dir, output_dir):
    if not os.path.isdir(image_dir) or len(os.listdir(image_dir)) == 0:
        print(f"❌ Image directory is missing or empty: {image_dir}")
        sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)
    db_path = os.path.join(output_dir, "database.db")
    sparse_dir = os.path.join(output_dir, "sparse")

    print("🔍 Step 1: Feature extraction")
    subprocess.run([
        "colmap", "feature_extractor",
        "--database_path", db_path,
        "--image_path", image_dir,
        "--ImageReader.single_camera", "1"
    ], check=True)

    print("🔗 Step 2: Exhaustive matching")
    subprocess.run([
        "colmap", "exhaustive_matcher",
        "--database_path", db_path
    ], check=True)

    print("🏗️ Step 3: Sparse reconstruction")
    os.makedirs(sparse_dir, exist_ok=True)
    subprocess.run([
        "colmap", "mapper",
        "--database_path", db_path,
        "--image_path", image_dir,
        "--output_path", sparse_dir
    ], check=True)

    print(f"✅ Sparse model completed at: {sparse_dir}")

    model_input = os.path.join(sparse_dir, "0")
    model_output = os.path.join(output_dir, "model.ply")

    if os.path.isdir(model_input):
        print("🧾 Step 4: Converting model to PLY")
        subprocess.run([
            "colmap", "model_converter",
            "--input_path", model_input,
            "--output_path", model_output,
            "--output_type", "PLY"
        ], check=True)
        print(f"🎯 Final PLY model saved at: {model_output}")
    else:
        print(f"⚠️ Warning: No model found at {model_input}. Skipping model conversion.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run COLMAP reconstruction and export PLY.")
    parser.add_argument("--images", default="./images", help="Path to image directory")
    parser.add_argument("--out", default="./output", help="Path to output directory")
    args = parser.parse_args()

    run_colmap(args.images, args.out)
