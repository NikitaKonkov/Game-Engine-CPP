#!/bin/bash

# Build script for Game-Engine-CPP

# Check if debug mode or clean mode is requested
DEBUG_MODE=0
CLEAN_MODE=0
BUILD_SDL3=0

if [ "$1" == "debug" ]; then
  DEBUG_MODE=1
  echo "Debug mode enabled"
elif [ "$1" == "clean" ]; then
  CLEAN_MODE=1  
  echo "Clean mode enabled"
elif [ "$1" == "build-sdl3" ]; then
  BUILD_SDL3=1
  echo "SDL3 build mode enabled"
fi

# Function to build SDL3
build_sdl3() {
  echo "Building SDL3..."
  
  # Create directory structure
  mkdir -p libs/sdl3
  
  # Clone SDL3 if needed
  if [ ! -d "libs/sdl3/SDL" ]; then
    echo "Cloning SDL3 repository..."
    git clone https://github.com/libsdl-org/SDL.git libs/sdl3/SDL || { 
      echo "Failed to clone SDL3 repository"; 
      exit 1; 
    }
  fi
  
  # Build SDL3
  mkdir -p libs/sdl3/SDL/build
  cd libs/sdl3/SDL/build || { echo "Failed to cd to SDL3 build directory"; exit 1; }
  
  echo "Configuring SDL3..."
  cmake .. -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DSDL_SHARED=ON \
      -DSDL_STATIC=OFF \
      -DSDL_TEST=OFF || { 
    echo "Failed to configure SDL3"; 
    cd ../../../../; 
    exit 1; 
  }
  
  echo "Building SDL3..."
  cmake --build . || { 
    echo "Failed to build SDL3"; 
    cd ../../../../; 
    exit 1; 
  }
  
  echo "Libraries in SDL3 build directory:"
  find . -name "*.a" -o -name "*.lib" | sort
  
  # Copy SDL3.dll to bin directory
  mkdir -p ../../../../bin
  if [ -f "SDL3.dll" ]; then
    echo "Copying SDL3.dll to bin directory..."
    cp SDL3.dll ../../../../bin/
  elif [ -f "Release/SDL3.dll" ]; then
    echo "Copying Release/SDL3.dll to bin directory..."
    cp Release/SDL3.dll ../../../../bin/
  else
    echo "Warning: Could not find SDL3.dll"
  fi
  
  cd ../../../../
}

# Build SDL3 if requested or if it doesn't exist
if [ $BUILD_SDL3 -eq 1 ] || [ ! -d "libs/sdl3/SDL/build" ]; then
  build_sdl3
fi

# Clean build if requested
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

# Create run.sh script
echo "Creating run.sh script..."
cat > run.sh << 'EOF'
#!/bin/bash

# Run script for Game-Engine-CPP
# This script builds and runs the game engine

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

# Check if SDL3.dll exists in bin directory, if not try to copy it
if [ ! -f "./bin/SDL3.dll" ]; then
  echo "Looking for SDL3.dll..."
  SDL3_DLL_PATH=""
  
  # Check possible locations
  if [ -f "./libs/sdl3/SDL/build/SDL3.dll" ]; then
    SDL3_DLL_PATH="./libs/sdl3/SDL/build/SDL3.dll"
  elif [ -f "./libs/sdl3/SDL/build/Release/SDL3.dll" ]; then
    SDL3_DLL_PATH="./libs/sdl3/SDL/build/Release/SDL3.dll"
  fi
  
  # Copy SDL3.dll if found
  if [ -n "$SDL3_DLL_PATH" ]; then
    echo "Found SDL3.dll at: $SDL3_DLL_PATH"
    mkdir -p ./bin
    cp "$SDL3_DLL_PATH" ./bin/
    echo "Copied SDL3.dll to bin directory"
  else
    echo "Warning: SDL3.dll not found, application may fail to run"
    echo "Consider running ./install.sh build-sdl3 to build SDL3"
  fi
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

# Check if SDL3.dll is in the same directory as the executable
if [ ! -f "./bin/SDL3.dll" ]; then
  echo "Warning: SDL3.dll not found in bin directory, application may fail to run"
fi

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
EOF

# Make run.sh executable
chmod +x run.sh
echo "run.sh created and made executable"

echo "Installation completed successfully!"
echo "To build and run your game engine, use: ./run.sh"
echo "For debug mode: ./run.sh debug"
echo "For clean build: ./run.sh clean"