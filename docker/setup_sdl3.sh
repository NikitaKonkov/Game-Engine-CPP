#!/bin/bash
# setup_sdl3.sh - Ensures SDL3 is properly installed and configured in Docker

# Show the current environment
echo "=== Current Environment ==="
echo "Working directory: $(pwd)"
echo "Library paths:"
ldconfig -p | grep -i sdl

# Check if SDL3 is already installed
if ldconfig -p | grep -q libSDL3; then
    echo "SDL3 is already installed and in the library path."
else
    echo "SDL3 not found in library path. Installing from source..."
    
    # Install build dependencies if not already installed
    apt-get update && apt-get install -y \
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
        wayland-protocols

    # Clone SDL3 repository
    git clone https://github.com/libsdl-org/SDL.git /tmp/SDL
    
    # Build SDL3
    cd /tmp/SDL
    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make -j$(nproc)
    make install
    ldconfig
    
    # Clean up
    cd /
    rm -rf /tmp/SDL
    
    echo "SDL3 has been built and installed."
fi

# Create symbolic links if necessary
if [ ! -f "/usr/local/lib/libSDL3.so" ] && [ -f "/usr/local/lib/libSDL3-3.0.so.0" ]; then
    echo "Creating symbolic link for libSDL3.so..."
    ln -sf /usr/local/lib/libSDL3-3.0.so.0 /usr/local/lib/libSDL3.so
    ldconfig
fi

# Verify installation
echo "=== Verification ==="
if [ -f "/usr/local/include/SDL3/SDL.h" ]; then
    echo "SDL3/SDL.h header found."
else
    echo "ERROR: SDL3/SDL.h header not found!"
fi

if ldconfig -p | grep -q libSDL3; then
    echo "libSDL3 library found in path."
else
    echo "ERROR: libSDL3 library not found in path!"
fi

echo "Library details:"
find /usr/local/lib -name "libSDL3*" | sort

echo "=== Setup Complete ==="