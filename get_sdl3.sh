#!/bin/bash
# Script to download and build SDL3 from source

# Create libs directory if it doesn't exist
mkdir -p ../libs/sdl3

# Navigate to libs directory
cd ../libs/sdl3

# Clone SDL3 repository
if [ ! -d "SDL" ]; then
    echo "Cloning SDL3 repository..."
    git clone https://github.com/libsdl-org/SDL.git
    cd SDL
else
    cd SDL
    echo "Updating SDL3 repository..."
    git pull
fi

# Create build directory
mkdir -p build
cd build

# Configure and build SDL3
echo "Configuring SDL3..."
cmake .. -DCMAKE_BUILD_TYPE=Release

echo "Building SDL3..."
cmake --build . --config Release

echo "SDL3 has been downloaded and built successfully!"

# Copy SDL3.dll to bin directory
echo "Copying SDL3.dll to bin directory..."
mkdir -p ../../../bin

# Try to find and copy SDL3.dll
if [ -f "SDL3.dll" ]; then
    cp SDL3.dll ../../../bin/
    echo "Copied SDL3.dll to bin directory"
elif [ -f "Debug/SDL3.dll" ]; then
    cp Debug/SDL3.dll ../../../bin/
    echo "Copied Debug/SDL3.dll to bin directory"
elif [ -f "Release/SDL3.dll" ]; then
    cp Release/SDL3.dll ../../../bin/
    echo "Copied Release/SDL3.dll to bin directory"
else
    echo "Warning: Could not find SDL3.dll to copy to bin directory"
fi

echo "Setup complete! You can now build and run your project."