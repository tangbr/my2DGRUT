FROM python:3.10-slim

# Install system dependencies for COLMAP and general usage
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libboost-all-dev \
    libeigen3-dev \
    libsuitesparse-dev \
    libfreeimage-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev \
    libatlas-base-dev \
    libflann-dev \
    libsqlite3-dev \
    libpng-dev \
    libjpeg-dev \
    libx11-dev \
    mesa-common-dev \
    libglu1-mesa-dev \  
    wget \
    ffmpeg \
    python3-opencv \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir opencv-python tqdm

# Clone COLMAP (CPU-only)
RUN git clone https://github.com/colmap/colmap.git /colmap

# Build COLMAP
WORKDIR /colmap
RUN mkdir build && cd build && \
cmake .. -DCUDA_ENABLED=OFF || (echo "==== CMakeOutput.log ====" && cat CMakeFiles/CMakeOutput.log || echo "No log found" && false)
    
# If cmake succeeds, build and install
WORKDIR /colmap/build
RUN make -j$(nproc) && make install    

# Create working directory
WORKDIR /app

# Copy your Python scripts into container
COPY extract_frames.py run_colmap.py ./

# Set default command to run both scripts
CMD ["sh", "-c", "python extract_frames.py && python run_colmap.py"]
