#!/bin/bash
# Build script for Game-Engine-CPP
# Usage: ./build.sh [debug|clean]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default build type
BUILD_TYPE="Release"

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

# Create build directory if it doesn't exist
mkdir -p build
mkdir -p bin
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

# Now look for the executable in the bin directory
if [ -d "$BIN_DIR" ]; then
    # Get the first executable file in the bin directory
    EXECUTABLE=$(find "$BIN_DIR" -type f -executable -print -quit)
    
    if [ -n "$EXECUTABLE" ]; then
        if [[ "$1" == "debug" ]]; then
            echo "Starting debugger..."
            gdb "$EXECUTABLE"
        else
            echo "Build successful! Press any key to run the application or Ctrl+C to exit."
            read -n 1 -s
            echo "Program started with $# argument(s)"
            for i in $(seq 0 $#); do
                echo "Argument $i: ${!i}"
            done
            echo "Running in normal mode (use 'debug' argument to run tests)"
            # Run executable directly without any X11 wrapper
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