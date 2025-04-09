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
    # SDL (alternative to GLFW)
    libsdl2-dev \
    # Debugging tools
    net-tools \
    iputils-ping \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Default command to run
CMD ["/bin/bash"]