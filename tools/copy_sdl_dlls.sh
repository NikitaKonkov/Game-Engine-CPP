#!/bin/bash
# Script to copy SDL3 DLLs to the bin directory

# Source paths
SDL3_BUILD_DIR="../libs/sdl3/SDL/build"
BIN_DIR="../bin"

# Create bin directory if it doesn't exist
mkdir -p "$BIN_DIR"

echo "Copying SDL3 DLLs to bin directory..."

# Find and copy SDL3.dll
if [ -f "$SDL3_BUILD_DIR/SDL3.dll" ]; then
    cp "$SDL3_BUILD_DIR/SDL3.dll" "$BIN_DIR/"
    echo "Copied SDL3.dll to $BIN_DIR"
elif [ -f "$SDL3_BUILD_DIR/Debug/SDL3.dll" ]; then
    cp "$SDL3_BUILD_DIR/Debug/SDL3.dll" "$BIN_DIR/"
    echo "Copied Debug/SDL3.dll to $BIN_DIR"
elif [ -f "$SDL3_BUILD_DIR/Release/SDL3.dll" ]; then
    cp "$SDL3_BUILD_DIR/Release/SDL3.dll" "$BIN_DIR/"
    echo "Copied Release/SDL3.dll to $BIN_DIR"
else
    echo "Error: Could not find SDL3.dll in build directories"
    exit 1
fi

echo "SDL3 DLLs have been copied to the bin directory successfully!"