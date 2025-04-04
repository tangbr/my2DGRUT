# Base image
FROM ubuntu:22.04

# Avoid prompts during installs
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake ninja-build build-essential \
    libboost-all-dev libceres-dev libsuitesparse-dev \
    libfreeimage-dev libgoogle-glog-dev libgflags-dev \
    libglew-dev libcgal-dev libatlas-base-dev libflann-dev \
    libeigen3-dev libsqlite3-dev libpng-dev libjpeg-dev \
    libx11-dev mesa-common-dev libglu1-mesa-dev libxrandr-dev \
    qtbase5-dev qtdeclarative5-dev qttools5-dev qtbase5-dev-tools \
    libqt5opengl5-dev wget ffmpeg python3 python3-pip python3-opencv meshlab \
    python3-setuptools python3-wheel python3-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python deps
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir tqdm opencv-python scikit-build

# Clone and patch COLMAP
RUN git clone https://github.com/colmap/colmap.git /colmap && \
    rm /colmap/cmake/FindFreeImage.cmake && \
    printf '%s\n' \
"if(NOT TARGET freeimage::FreeImage)" \
"  add_library(freeimage::FreeImage INTERFACE IMPORTED)" \
"  set_target_properties(freeimage::FreeImage PROPERTIES" \
"      INTERFACE_INCLUDE_DIRECTORIES \"/usr/include\"" \
"      INTERFACE_LINK_LIBRARIES \"FreeImage\")" \
"endif()" > /colmap/cmake/FindFreeImage.cmake

# Build COLMAP without CUDA
RUN rm -rf /colmap/build && mkdir /colmap/build
RUN cmake .. \
    -DCUDA_ENABLED=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DMETIS_INCLUDE_DIR="/usr/include" \
    -DMETIS_LIBRARY="/usr/lib/x86_64-linux-gnu/libmetis.so" && \
    make -j"$(nproc)" && \
    make install

# Clone 3DGRUT
WORKDIR /app
RUN git clone https://github.com/nv-tlabs/3dgrut.git && \
    cd 3dgrut && \
    pip3 install -r requirements.txt

# Copy your processing scripts
COPY extract_frames.py run_colmap.py docker_entrypoint.sh /app/
RUN chmod +x /app/docker_entrypoint.sh

# Default entrypoint
ENTRYPOINT ["/app/docker_entrypoint.sh"]
CMD ["/app/data/my_video.mp4", "default_user"]
