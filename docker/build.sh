#!/bin/bash
# Build script for Game-Engine-CPP
# Usage: ./build.sh [debug|clean|xvfb]

set -e

# Get project directory and script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
echo "Project directory: ${PROJECT_DIR}"
echo "Script directory: ${SCRIPT_DIR}"

# Default build type
BUILD_TYPE="Release"
USE_XVFB=0

# Output directory - store build files in project root
BUILD_DIR="${PROJECT_DIR}/build"
BIN_DIR="${PROJECT_DIR}/bin"

echo "Build directory: ${BUILD_DIR}"
echo "Binary directory: ${BIN_DIR}"

# Process arguments
if [[ "$1" == "debug" ]]; then
    BUILD_TYPE="Debug"
    echo "Building in Debug mode"
fi

# Clean option
if [[ "$1" == "clean" ]]; then
    echo "Cleaning build directory"
    rm -rf "${BUILD_DIR}"
    rm -rf "${BIN_DIR}"
fi

# Xvfb option
if [[ "$1" == "xvfb" ]]; then
    USE_XVFB=1
    echo "Will run with Xvfb virtual display"
fi

# Check if build exists and is a file (not a directory)
if [ -e "${BUILD_DIR}" ] && [ ! -d "${BUILD_DIR}" ]; then
    echo "Error: 'build' exists but is not a directory. Removing it..."
    rm -f "${BUILD_DIR}"
fi

# Create build and bin directories if they don't exist
mkdir -p "${BUILD_DIR}"
mkdir -p "${BIN_DIR}"

# Ensure SDL3 is installed and properly configured
echo "Checking SDL3 installation..."
chmod +x "${SCRIPT_DIR}/setup_sdl3.sh"
"${SCRIPT_DIR}/setup_sdl3.sh"

# Make sure our CMake modules directory exists
mkdir -p "${SCRIPT_DIR}/cmake"

# Change to build directory
cd "${BUILD_DIR}"

# Configure with CMake
echo "Configuring project with CMake..."
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="${BIN_DIR}" \
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="${BIN_DIR}" \
      -DCMAKE_MODULE_PATH="${SCRIPT_DIR}/cmake" \
      "${PROJECT_DIR}"

# Build the project
echo "Building project..."
cmake --build . --config "${BUILD_TYPE}"

# Copy executable from build directory to bin if it wasn't placed there
if [ ! -f "${BIN_DIR}/GameEngine" ] && [ -f "${BUILD_DIR}/GameEngine" ]; then
    echo "Copying executable from build to bin directory..."
    cp "${BUILD_DIR}/GameEngine" "${BIN_DIR}/"
fi

# Copy SDL3 library if it exists
if [ -f "/usr/local/lib/libSDL3.so" ]; then
    echo "Copying SDL3 libraries to bin directory..."
    cp /usr/local/lib/libSDL3* "${BIN_DIR}/"
fi

# Make sure PATH/LD_LIBRARY_PATH includes SDL3 library location
export LD_LIBRARY_PATH="${BIN_DIR}:/usr/local/lib:${LD_LIBRARY_PATH}"

# Now look for the executable in the bin directory
if [ -d "${BIN_DIR}" ]; then
    # Get the first executable file in the bin directory
    EXECUTABLE=$(find "${BIN_DIR}" -type f -executable -name "GameEngine" -print -quit)
    
    if [ -n "${EXECUTABLE}" ]; then
        if [[ "$1" == "debug" ]]; then
            echo "Starting debugger..."
            gdb "${EXECUTABLE}"
        elif [[ "${USE_XVFB}" == "1" ]]; then
            echo "Running with Xvfb virtual display..."
            chmod +x "${SCRIPT_DIR}/run_with_xvfb.sh"
            "${SCRIPT_DIR}/run_with_xvfb.sh" "${EXECUTABLE}"
        else
            echo "Build successful! Press any key to run the application or Ctrl+C to exit."
            read -n 1 -s
            echo "Running in normal mode"
            "${EXECUTABLE}"
        fi
    else
        echo "No executable found in ${BIN_DIR}"
        echo "Looking for executable in build directory..."
        EXECUTABLE=$(find "${BUILD_DIR}" -type f -executable -name "GameEngine" -print -quit)
        if [ -n "${EXECUTABLE}" ]; then
            echo "Found executable in build directory: ${EXECUTABLE}"
            echo "Copying to bin directory..."
            cp "${EXECUTABLE}" "${BIN_DIR}/"
            echo "Press any key to run the application or Ctrl+C to exit."
            read -n 1 -s
            "${BIN_DIR}/GameEngine"
        else
            echo "No executable found. Build may have failed."
            exit 1
        fi
    fi
else
    echo "Bin directory not found at ${BIN_DIR}"
    exit 1
fi