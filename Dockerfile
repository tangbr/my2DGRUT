FROM python:3.10-slim

# Install system dependencies for COLMAP
RUN apt-get update && apt-get install -y xvfb \
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
    libglu1-mesa-dev \
    libxrandr-dev \
    qtbase5-dev \
    qtdeclarative5-dev \
    qttools5-dev \
    qtbase5-dev-tools \
    wget \
    ffmpeg \
    python3-opencv \
    libmetis-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir opencv-python tqdm

# Clone COLMAP (do not disable METIS detection so that it links properly)
RUN git clone https://github.com/colmap/colmap.git /colmap

# Set working directory for build setup
WORKDIR /colmap/build

# Clean any existing build files and reconfigure CMake
RUN rm -rf * && \
    cmake .. \
        -DCUDA_ENABLED=OFF \
        -DCMAKE_VERBOSE_MAKEFILE=ON && \
    make -j$(nproc) > /tmp/make_output.log 2>&1 || (cat /tmp/make_output.log && false) && \
    make install

# Create working directory and copy scripts
WORKDIR /app
COPY extract_frames.py run_colmap.py ./

# Run both Python scripts
CMD ["bash", "-c", "python extract_frames.py && python run_colmap.py"]
