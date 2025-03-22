FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libboost-all-dev \
    libglew-dev \
    libeigen3-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libfreeimage-dev \
    libmetis-dev \
    libopencv-dev \
    wget \
    unzip \
    && apt-get clean

# Clone COLMAP (CPU-only)
# Replace with the correct URL
RUN git clone https://github.com/colmap/colmap.git /colmap

# Build COLMAP
WORKDIR /colmap
RUN mkdir build && cd build && \
    cmake .. -DCUDA_ENABLED=OFF && \
    make -j$(nproc) && make install

# Copy your scripts
WORKDIR /app
COPY extract_frames.py .
COPY run_colmap.py .

# Set default command (run both scripts)
CMD ["bash", "-c", "python extract_frames.py && python run_colmap.py"]
