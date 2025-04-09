#!/bin/bash
# run_with_xvfb.sh - Run SDL applications with Xvfb virtual display

# Configuration
XVFB_DISPLAY=:99
SCREEN_WIDTH=1280
SCREEN_HEIGHT=720
SCREEN_DEPTH=24
EXECUTABLE=${1:-"./build/GameEngine"}
VNC_PORT=5900

# Ensure XDG_RUNTIME_DIR exists and has proper permissions
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/tmp/xdg-runtime-dir"
    echo "XDG_RUNTIME_DIR not set, using $XDG_RUNTIME_DIR"
fi

# Create XDG_RUNTIME_DIR if it doesn't exist
mkdir -p "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"
echo "XDG_RUNTIME_DIR set to $XDG_RUNTIME_DIR with proper permissions"

# Check if Xvfb is installed, and try to install it if not available
if ! command -v Xvfb &> /dev/null; then
    echo "Xvfb not found! Attempting to install it..."
    
    # Check if we can use apt-get (Debian/Ubuntu)
    if command -v apt-get &> /dev/null; then
        echo "Updating package lists..."
        apt-get update || { echo "Failed to update package lists"; exit 1; }
        
        echo "Installing Xvfb and related packages..."
        apt-get install -y xvfb x11-xserver-utils x11vnc || { 
            echo "Failed to install Xvfb. Try manually with: apt-get update && apt-get install -y xvfb x11-xserver-utils x11vnc";
            exit 1;
        }
    # Check if we can use yum (Fedora/CentOS/RHEL)
    elif command -v yum &> /dev/null; then
        echo "Installing Xvfb using yum..."
        yum -y install xorg-x11-server-Xvfb x11vnc || {
            echo "Failed to install Xvfb. Try manually with: yum install -y xorg-x11-server-Xvfb x11vnc";
            exit 1;
        }
    # Check if we can use apk (Alpine)
    elif command -v apk &> /dev/null; then
        echo "Installing Xvfb using apk..."
        apk add xvfb x11vnc || {
            echo "Failed to install Xvfb. Try manually with: apk add xvfb x11vnc";
            exit 1;
        }
    else
        echo "ERROR: Could not determine package manager to install Xvfb."
        echo "Please install Xvfb manually and try again."
        exit 1
    fi

    # Verify installation succeeded
    if ! command -v Xvfb &> /dev/null; then
        echo "ERROR: Xvfb installation failed or executable not in PATH."
        exit 1
    fi
    
    echo "Xvfb successfully installed."
fi

# Stop any existing Xvfb processes
echo "Stopping any existing Xvfb processes..."
pkill Xvfb || true
sleep 1

echo "Starting Xvfb on display $XVFB_DISPLAY with resolution ${SCREEN_WIDTH}x${SCREEN_HEIGHT}..."
Xvfb $XVFB_DISPLAY -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Ensure Xvfb is properly terminated on script exit
cleanup() {
    echo "Cleaning up..."
    if [ -n "$XVFB_PID" ]; then
        echo "Terminating Xvfb (PID: $XVFB_PID)"
        kill $XVFB_PID || true
    fi
    if [ -n "$X11VNC_PID" ]; then
        echo "Terminating x11vnc (PID: $X11VNC_PID)"
        kill $X11VNC_PID || true
    fi
}
trap cleanup EXIT

# Wait for Xvfb to initialize
sleep 2

# Check if Xvfb is running
if ! ps -p $XVFB_PID > /dev/null; then
    echo "Failed to start Xvfb!"
    exit 1
fi

echo "Xvfb started successfully with PID: $XVFB_PID"

# Get container hostname and IP for VNC connection info
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -i 2>/dev/null || echo "127.0.0.1")

# Optional: Start x11vnc for remote viewing if available
if command -v x11vnc &> /dev/null; then
    echo "Starting x11vnc server for remote viewing..."
    x11vnc -display $XVFB_DISPLAY -nopw -forever -quiet &
    X11VNC_PID=$!
    
    echo ""
    echo "============= VNC CONNECTION INFO ============="
    echo "VNC server started on ${HOSTNAME}:${VNC_PORT}"
    echo "To connect from Docker host:"
    echo "  - Use a VNC viewer to connect to: localhost:${VNC_PORT}"
    echo ""
    echo "Connection options:"
    echo "  1. Docker Desktop: Use the 'PORT' link next to container"
    echo "  2. VS Code: Click 'PORTS' tab and look for ${VNC_PORT}"
    echo "  3. Command line: Use 'docker port <container_id> ${VNC_PORT}'"
    echo "================================================"
    echo ""
fi

# Export the display variable to use our virtual display
export DISPLAY=$XVFB_DISPLAY

# Check if the executable exists and is executable
if [ ! -x "$EXECUTABLE" ]; then
    echo "Warning: '$EXECUTABLE' is not executable or does not exist."
    echo "Searching for the GameEngine executable..."
    
    # Try to find the executable in standard locations
    possible_locations=(
        "./build/GameEngine"
        "./bin/GameEngine"
        "../build/GameEngine"
        "../bin/GameEngine"
        "/app/build/GameEngine"
        "/app/bin/GameEngine"
        "/app/docker/build/GameEngine"
        "/app/docker/bin/GameEngine"
    )
    
    for location in "${possible_locations[@]}"; do
        if [ -x "$location" ]; then
            EXECUTABLE="$location"
            echo "Found executable at: $EXECUTABLE"
            break
        fi
    done
    
    # Final check if executable was found
    if [ ! -x "$EXECUTABLE" ]; then
        echo "ERROR: Could not find executable GameEngine in standard locations."
        exit 1
    fi
fi

# Run the specified executable
echo "Running '$EXECUTABLE' on virtual display $DISPLAY"
echo "Starting application..."
$EXECUTABLE
EXIT_CODE=$?
echo "Application exited with code: $EXIT_CODE"

# Cleanup happens automatically via the trap