FROM ubuntu:22.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    gdb \
    git \
    pkg-config \
    # OpenGL dependencies
    libglfw3-dev \
    libglew-dev \
    libglm-dev \
    libassimp-dev \
    # Headless OpenGL support
    mesa-utils \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    # Xvfb for virtual display - use x11-xvfb package on Ubuntu
    x11-xserver-utils \
    xvfb \
    x11vnc \
    # SDL3 build dependencies
    libpulse-dev \
    libasound2-dev \
    libxext-dev \
    libx11-dev \
    libxcursor-dev \
    libxinerama-dev \
    libxi-dev \
    libxrandr-dev \
    libxss-dev \
    libwayland-dev \
    libxkbcommon-dev \
    wayland-protocols \
    # Debugging tools
    net-tools \
    iputils-ping \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Build and install SDL3 from source
RUN git clone https://github.com/libsdl-org/SDL.git /tmp/SDL \
    && cd /tmp/SDL \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && cd / \
    && rm -rf /tmp/SDL

# Set up working directory
WORKDIR /app

# Default command to run
CMD ["/bin/bash"]