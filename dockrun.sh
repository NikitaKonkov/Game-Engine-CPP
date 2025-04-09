#!/bin/sh
# Simple Docker build and run script for MSYS2

# Function to print messages
print_msg() {
    echo "==> $1"
}

# Check for Docker
if ! command -v docker > /dev/null 2>&1; then
    echo "ERROR: Docker not found. Please install Docker and ensure it's in your PATH"
    exit 1
fi

# Simple parse command line arguments
if [ "$1" = "build" ] || [ -z "$1" ]; then
    print_msg "Building Docker image..."
    docker build -t game-engine-cpp docker
    
elif [ "$1" = "run" ]; then
    print_msg "Running Docker container..."
    docker run --rm -it -v "$(pwd)":/app game-engine-cpp /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
    
elif [ "$1" = "shell" ]; then
    print_msg "Opening shell in Docker container..."
    docker run --rm -it -v "$(pwd)":/app game-engine-cpp /bin/bash
    
elif [ "$1" = "clean" ]; then
    print_msg "Cleaning Docker resources..."
    docker rm -f game-engine-cpp-dev 2>/dev/null
    docker rmi -f game-engine-cpp 2>/dev/null
    
elif [ "$1" = "rebuild" ]; then
    print_msg "Cleaning and rebuilding Docker..."
    docker rm -f game-engine-cpp-dev 2>/dev/null
    docker rmi -f game-engine-cpp 2>/dev/null
    docker build -t game-engine-cpp docker
    
elif [ "$1" = "compile" ]; then
    print_msg "Building project inside Docker..."
    docker run --rm -it -v "$(pwd)":/app game-engine-cpp /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
    
elif [ "$1" = "direct-run" ]; then
    print_msg "Directly running the executable..."
    docker run --rm -it -v "$(pwd)":/app game-engine-cpp /bin/bash -c "cd /app/bin && ./GameEngine"
    
else
    echo "Usage: $0 {build|run|shell|clean|rebuild|compile|direct-run}"
    echo ""
    echo "  build      - Build Docker image (default)"
    echo "  run        - Run the application in Docker with build step"
    echo "  shell      - Open a shell in the Docker container"
    echo "  clean      - Remove Docker image and containers"
    echo "  rebuild    - Clean and rebuild Docker image"
    echo "  compile    - Build the project inside Docker"
    echo "  direct-run - Directly run the executable without build or prompt"
fi