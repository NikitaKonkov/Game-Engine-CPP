#!/bin/bash
# Script to build and install SDL3 for your project
# Usage: ./build_sdl3.sh

# Set working directory to script location
cd "$(dirname "$0")"

# Create necessary directories
mkdir -p libs/sdl3
mkdir -p bin

# Clone SDL3 if needed
if [ ! -d "libs/sdl3/SDL" ]; then
    echo "Cloning SDL3 repository..."
    git clone https://github.com/libsdl-org/SDL.git libs/sdl3/SDL
else
    echo "SDL3 repository already exists, updating..."
    cd libs/sdl3/SDL
    git pull
    cd ../../..
fi

# Create build directory
mkdir -p libs/sdl3/SDL/build
cd libs/sdl3/SDL/build

# Configure and build SDL3
echo "Configuring SDL3..."
cmake .. -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DSDL_SHARED=ON \
    -DSDL_STATIC=OFF \
    -DSDL_TEST=OFF

echo "Building SDL3..."
cmake --build . 

echo "SDL3 build complete!"

# Copy SDL3.dll to bin directory
if [ -f "SDL3.dll" ]; then
    echo "Copying SDL3.dll to bin directory..."
    cp SDL3.dll ../../../../bin/
elif [ -f "Release/SDL3.dll" ]; then
    echo "Copying Release/SDL3.dll to bin directory..."
    cp Release/SDL3.dll ../../../../bin/
else
    echo "Warning: Could not find SDL3.dll"
fi

# Print information about the build
echo "Libraries in build directory:"
find . -name "*.a" -o -name "*.lib" | sort

echo "DLLs in build directory:"
find . -name "*.dll" | sort

echo "SDL3 build complete and files copied to project."
cd ../../../..

echo "You can now build your project with ./msysrun.sh"