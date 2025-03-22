# Base image
FROM python:3.10-slim

# Set working directory
WORKDIR /workspace

# Install system dependencies for COLMAP and Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential libboost-all-dev libeigen3-dev \
    libflann-dev libfreeimage-dev libgoogle-glog-dev libgflags-dev \
    libglew-dev qtbase5-dev libqt5opengl5-dev libcgal-dev \
    libsqlite3-dev wget unzip libatlas-base-dev libopencv-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build COLMAP (CPU-only)
RUN git clone https://github.com/facebookresearch/colmap.git && \
    cd colmap && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DGUI_ENABLED=OFF -DOPENMP_ENABLED=ON && \
    make -j$(nproc) && make install

# Install Python packages
RUN pip install opencv-python numpy

# Create folders
RUN mkdir -p /workspace/video /workspace/images

# Copy video and scripts
COPY data/my_video.mp4 /workspace/video/my_video.mp4
COPY extract_frames.py /workspace/extract_frames.py
COPY run_colmap.py /workspace/run_colmap.py

# Run both scripts in sequence
CMD python extract_frames.py && python run_colmap.py
