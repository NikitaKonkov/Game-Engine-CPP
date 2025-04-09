#!/bin/bash
# Build script for Game-Engine-CPP
# Usage: ./build.sh [debug|clean|xvfb]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default build type
BUILD_TYPE="Release"
USE_XVFB=0

# Output directory - changed to match Docker container path
BIN_DIR="$SCRIPT_DIR/bin"

# Process arguments
if [[ "$1" == "debug" ]]; then
    BUILD_TYPE="Debug"
    echo "Building in Debug mode"
fi

# Clean option
if [[ "$1" == "clean" ]]; then
    echo "Cleaning build directory"
    rm -rf build
    rm -rf bin
fi

# Xvfb option
if [[ "$1" == "xvfb" ]]; then
    USE_XVFB=1
    echo "Will run with Xvfb virtual display"
fi

# Create build directory if it doesn't exist
mkdir -p build
mkdir -p bin

# Ensure SDL3 is installed and properly configured
echo "Checking SDL3 installation..."
chmod +x "$SCRIPT_DIR/setup_sdl3.sh"
"$SCRIPT_DIR/setup_sdl3.sh"

# Make sure our CMake modules directory exists
mkdir -p "$SCRIPT_DIR/cmake"

cd build

# Configure with CMake
echo "Configuring project with CMake..."
cmake -G Ninja -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$BIN_DIR" \
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$BIN_DIR" ..

# Build the project
echo "Building project..."
cmake --build . --config "$BUILD_TYPE"

# Copy executable from build directory to bin if it wasn't placed there
if [ ! -f "$BIN_DIR/GameEngine" ] && [ -f "$SCRIPT_DIR/build/GameEngine" ]; then
    echo "Copying executable from build to bin directory..."
    cp "$SCRIPT_DIR/build/GameEngine" "$BIN_DIR/"
fi

# Copy SDL3 library if it exists
if [ -f "/usr/local/lib/libSDL3.so" ]; then
    echo "Copying SDL3 libraries to bin directory..."
    cp /usr/local/lib/libSDL3* "$BIN_DIR/"
fi

# Make sure PATH/LD_LIBRARY_PATH includes SDL3 library location
export LD_LIBRARY_PATH="$BIN_DIR:/usr/local/lib:$LD_LIBRARY_PATH"

# Now look for the executable in the bin directory
if [ -d "$BIN_DIR" ]; then
    # Get the first executable file in the bin directory
    EXECUTABLE=$(find "$BIN_DIR" -type f -executable -name "GameEngine" -print -quit)
    
    if [ -n "$EXECUTABLE" ]; then
        if [[ "$1" == "debug" ]]; then
            echo "Starting debugger..."
            gdb "$EXECUTABLE"
        elif [[ "$USE_XVFB" == "1" ]]; then
            echo "Running with Xvfb virtual display..."
            chmod +x "$SCRIPT_DIR/run_with_xvfb.sh"
            "$SCRIPT_DIR/run_with_xvfb.sh" "$EXECUTABLE"
        else
            echo "Build successful! Press any key to run the application or Ctrl+C to exit."
            read -n 1 -s
            echo "Program started with $# argument(s)"
            for i in $(seq 0 $#); do
                echo "Argument $i: ${!i}"
            done
            echo "Running in normal mode (use 'debug' argument to run tests)"
            "$EXECUTABLE"
        fi
    else
        echo "No executable found in $BIN_DIR"
        exit 1
    fi
else
    echo "Bin directory not found at $BIN_DIR"
    exit 1
fi