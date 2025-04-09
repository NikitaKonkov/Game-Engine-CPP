#!/bin/bash

# Build script for Game-Engine-CPP

# Check if debug mode or clean mode is requested
DEBUG_MODE=0
CLEAN_MODE=0
if [ "$1" == "debug" ]; then
  DEBUG_MODE=1
  echo "Debug mode enabled"
elif [ "$1" == "clean" ]; then
  CLEAN_MODE=1  
  echo "Clean mode enabled"
fi

if [ $CLEAN_MODE -eq 1 ]; then
  echo "Deleting old build files..."
  rm -rf build || { echo "Failed to delete old build files"; exit 1; }
fi

# Ensure debugger directory exists
mkdir -p debugger

# Make sure debugger script is executable
if [ -f "./debugger/gdb_enhanced_debugger.sh" ]; then
  chmod +x ./debugger/gdb_enhanced_debugger.sh
  echo "Debugger script permissions updated"
fi

echo "Creating build directory..."
mkdir -p build && cd build || { echo "Failed to create/enter build directory"; exit 1; }

echo "Configuring project with CMake..."
cmake -G Ninja .. || { echo "CMake configuration failed"; exit 1; }

echo "Building project..."
cmake --build . --config Release || { echo "Build failed"; exit 1; }

echo "Returning to project root..."
cd ..

echo "Build completed successfully!"
echo "Executable location: $(pwd)/bin/GameEngine.exe"

# Wait for key press before launching
echo ""
if [ $DEBUG_MODE -eq 1 ]; then
  echo "Press any key to launch GameEngine with debugger..."
else
  echo "Press any key to launch GameEngine..."
fi
read -n 1 -s

# Launch the program (with or without debugger)
if [ $DEBUG_MODE -eq 1 ]; then
    echo "Launching GameEngine with debug flag..."
    
    # Check if debugger script exists
    if [ -f "./debugger/gdb_enhanced_debugger.sh" ]; then
        echo "Using enhanced debugger..."
        ./debugger/gdb_enhanced_debugger.sh bin/GameEngine.exe debug
    else
        echo "Debugger script not found, running with debug flag directly..."
        bin/GameEngine.exe debug || { echo "Failed to launch GameEngine"; exit 1; }
    fi
else
    echo "Launching GameEngine..."
    bin/GameEngine.exe || { echo "Failed to launch GameEngine"; exit 1; }
fi