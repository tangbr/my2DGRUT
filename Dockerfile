FROM python:3.10-slim

# Install system dependencies for COLMAP and general usage
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libboost-all-dev \
    libceres-dev \
    libsuitesparse-dev \
    libfreeimage-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libglew-dev \
    libcgal-dev \
    libatlas-base-dev \
    libflann-dev \
    libeigen3-dev \
    libsqlite3-dev \
    libpng-dev \
    libjpeg-dev \
    libx11-dev \
    mesa-common-dev \
    libglu1-mesa-dev\
    libxrandr-dev \
    qtbase5-dev \
    qtchooser \
    qt5-qmake \
    qtbase5-dev-tools \
    wget \
    ffmpeg \
    python3-opencv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir opencv-python tqdm

# Copy your Python scripts into container
COPY extract_frames.py run_colmap.py ./

# Clone COLMAP (CPU-only)
RUN git clone https://github.com/colmap/colmap.git /colmap

# Build COLMAP
WORKDIR /colmap
RUN mkdir build
WORKDIR /colmap/build
RUN cmake .. \
    -DCUDA_ENABLED=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=ON


#|| (echo "==== CMakeOutput.log ====" && cat CMakeFiles/CMakeOutput.log || echo "No log found" && false)
    
# If cmake succeeds, build and install

RUN make -j$(nproc) && make install    

# Create working directory
WORKDIR /app

# Set default command to run both scripts
CMD ["bash", "-c", "python extract_frames.py && python run_colmap.py"]
