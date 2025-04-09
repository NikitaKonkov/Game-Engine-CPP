#!/bin/sh
# Simple Docker build and run script for Linux/MSYS2

# Constants
IMAGE_NAME="game-engine-cpp"
CONTAINER_NAME="game-engine-cpp-dev"

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
if [ -z "$1" ]; then
    # Show usage if no arguments provided
    CMD="usage"
else
    CMD="$1"
fi

case "$CMD" in
    "build")
        print_msg "Building Docker image..."
        docker build -t ${IMAGE_NAME} docker
        print_msg "Build complete!"
        ;;
    
    "run")
        print_msg "Running the application in Docker..."
        docker run --rm -it \
          -v "$(pwd)":/app \
          ${IMAGE_NAME} /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
        ;;
    
    "debug")
        print_msg "Running the application in debug mode in Docker..."
        docker run --rm -it \
          -v "$(pwd)":/app \
          ${IMAGE_NAME} /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh debug"
        ;;
    
    "clean")
        print_msg "Cleaning Docker resources..."
        docker run --rm -v "$(pwd)":/app ${IMAGE_NAME} /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh clean" 2>/dev/null
        docker rm -f ${CONTAINER_NAME} 2>/dev/null
        docker rmi -f ${IMAGE_NAME} 2>/dev/null
        print_msg "Clean complete!"
        ;;
    
    "rebuild")
        print_msg "Cleaning and rebuilding Docker..."
        # Clean
        docker run --rm -v "$(pwd)":/app ${IMAGE_NAME} /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh clean" 2>/dev/null
        docker rm -f ${CONTAINER_NAME} 2>/dev/null
        docker rmi -f ${IMAGE_NAME} 2>/dev/null
        
        # Build
        print_msg "Building Docker image..."
        docker build -t ${IMAGE_NAME} docker
        print_msg "Build complete!"
        ;;
    
    "compile")
        print_msg "Compiling the project inside Docker..."
        docker run --rm -it -v "$(pwd)":/app ${IMAGE_NAME} /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
        ;;
    
    "shell")
        print_msg "Opening a shell inside the Docker container..."
        docker run --rm -it \
          -v "$(pwd)":/app \
          ${IMAGE_NAME} /bin/bash
        ;;
    
    "direct-run")
        print_msg "Directly running the executable..."
        docker run --rm -it -v "$(pwd)":/app ${IMAGE_NAME} /bin/bash -c "cd /app/bin && ./GameEngine"
        ;;
    
    *)
        # Usage as default
        echo "Usage: $0 {build|run|debug|clean|rebuild|compile|direct-run|shell}"
        echo ""
        echo "  build      - Build Docker image"
        echo "  run        - Run the application in Docker with build step"
        echo "  debug      - Run the application in debug mode in Docker"
        echo "  clean      - Remove Docker image and containers"
        echo "  rebuild    - Clean and rebuild Docker image"
        echo "  compile    - Build the project inside Docker"
        echo "  direct-run - Directly run the executable without build or prompt"
        echo "  shell      - Get a shell inside the Docker container"
        ;;
esac