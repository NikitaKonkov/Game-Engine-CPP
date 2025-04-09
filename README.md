## Game-Engine-CPP
Welcome to the Game-Engine-CPP project! This README will guide you through setting up your development environment and building the project using either MSYS2 and CMake or Docker.

# Option 1: Using MSYS2 (Recommended)

### Prerequisites
Before you start, make sure you have the following installed:
- Windows 10 or later
- MSYS2 UCRT64 environment

### Setting Up MSYS2
1. Download the MSYS2 installer from the official website:
   - [msys2-x86_64-20250221.exe](https://github.com/msys2/msys2-installer/releases/download/2025-02-21/msys2-x86_64-20250221.exe)
2. Run the installer and follow the installation wizard. Make sure to install MSYS2 to the `C:\` root directory.
3. After installation, open the "MSYS2 UCRT64" terminal from the Start menu.

### Installing Required Packages
In the MSYS2 UCRT64 terminal, run the following commands to install the necessary packages:
```bash
pacman -Syu
pacman -S mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-make mingw-w64-ucrt-x86_64-gdb
```
This will install:
- CMake (build system)
- Ninja (build tool)
- GCC (C++ compiler)
- Make (build tool)
- GDB (debugger)

### Setting Up SDL3
SDL3 (Simple DirectMedia Layer) is used for cross-platform graphics, audio, and input handling. To set up SDL3:

1. Run the provided script to download and build SDL3 from source:
   ```bash
   cd tools
   chmod +x get_sdl3.sh
   ./get_sdl3.sh
   ```
   
   This script will:
   - Clone the SDL3 repository from GitHub
   - Build SDL3 with CMake
   - Configure it for use with your project

2. Alternatively, you can install SDL3 manually:
   ```bash
   # Clone SDL3 repository
   git clone https://github.com/libsdl-org/SDL.git libs/sdl3/SDL
   
   # Build SDL3
   cd libs/sdl3/SDL
   mkdir -p build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   cmake --build . --config Release
   ```

3. To verify SDL3 was installed correctly:
   ```bash
   # The CMake configuration should automatically find SDL3
   # when building your project if it's in the libs/sdl3 directory
   ```

### Verifying CMake Installation
To check the version of CMake installed, run:
```bash
cmake --version
```
Make sure the version is 3.14 or higher.

### Building the Project
1. Clone the Game-Engine-CPP repository or download the source code.
2. In the MSYS2 UCRT64 terminal, navigate to the project directory:
   ```bash
   cd /c/path/to/Game-Engine-CPP
   ```
3. Run the build script:
   ```bash
   ./msysrun.sh
   ```
   This will create a `build` directory, configure the project with CMake, and build the executable.
4. After the build completes, press any key to launch the game engine.

### Debugging with GDB
To debug the game engine with GDB, run the build script with the `debug` flag:
```bash
./msysrun.sh debug
```
This will build the project and launch it with GDB. You can use the following GDB commands:
- `run` - Start the program
- `break main` - Set a breakpoint at the main function
- `next` - Step over to the next line
- `step` - Step into a function
- `continue` - Resume execution until the next breakpoint
- `quit` - Exit the debugger

### Clean Build
To perform a clean build, which deletes the old build files and does a fresh build, run the build script with the `clean` flag:
```bash
./msysrun.sh clean
```
This will delete the `build` directory, create a new one, configure the project with CMake, and build the executable. After the build completes, press any key to launch the game engine normally (without the debugger).

<br>
<br>
<br>
<br>

# Option 2: Using Docker

### Prerequisites
Before you start, make sure you have the following installed:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Windows or Docker Engine for Linux
- Docker Compose (included with Docker Desktop for Windows)

### Getting Started with Docker

#### Quick Start with dockrun.bat

We provide a convenient batch script `dockrun.bat` to manage Docker operations:

```cmd
dockrun.bat {build|run|shell|clean|rebuild|compile|direct-run}
```

Commands:
- `build` - Build the Docker image
- `run` - Build and run the application (with interactive prompt)
- `shell` - Open an interactive shell in the container
- `clean` - Remove Docker image and containers
- `rebuild` - Clean and rebuild Docker image
- `compile` - Build the project inside Docker
- `direct-run` - Directly run the executable without build or prompt

Typical workflow:
```cmd
# First time setup
dockrun.bat build

# Open Docker shell for development
dockrun.bat shell
```

#### Manual Docker Commands

If you prefer using Docker directly:

**For Windows users**:
```cmd
# Build the Docker image
docker build -t game-engine-cpp .
   
# Run the container with interactive shell
docker run -it --rm -v "%CD%":/app game-engine-cpp bash
```

**For Linux/macOS users**:
```bash
# Build the Docker image
docker build -t game-engine-cpp .
   
# Run the container with interactive shell
docker run -it --rm -v "$(pwd)":/app game-engine-cpp bash
```

### Working in Docker Shell Environment

#### Building and Running the Project

Once inside the Docker shell (after running `dockrun.bat shell`), you can build and run the project:

```bash
# Navigate to the docker directory
cd /app/docker

# Build the project using the provided build script
./build.sh

# To build in debug mode
./build.sh debug

# To run the executable directly
cd /app/bin
./GameEngine
```

#### Using Xvfb for Graphical Applications

Since Docker containers don't have a physical display, you need to use Xvfb to run SDL applications with graphics:

```bash
# Navigate to the docker directory
cd /app/docker

# Build and run with Xvfb virtual display
./build.sh xvfb
```

This will:
1. Set up a virtual X11 display (`:99`)
2. Start an x11vnc server for remote viewing (on port 5900)
3. Run your SDL application on the virtual display

**NOTE**: Always use the `xvfb` parameter with the build script when running graphical applications inside the Docker container.

### Connecting with VNC to See Graphical Output

You can view your application's graphical output using a VNC client:

1. **Using VNC Viewer**:
   - Install a VNC viewer like [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/), [TightVNC](https://www.tightvnc.com/), or [VNC Viewer for Google Chrome](https://chrome.google.com/webstore/detail/vnc-viewer-for-google-chr/iabmpiboiopbgfabjmgeedhcmjenhbla)
   - Connect to `localhost:5900`

2. **Using VS Code**:
   - If you're using VS Code with the Docker extension, you can:
   - Look for the "PORTS" tab in the Docker extension
   - Find port 5900 and click on "Open in Browser" or copy the link

3. **Docker Desktop**:
   - In Docker Desktop, select your running container
   - Find port 5900 in the "PORT MAPPING" section
   - Click to open or copy the link

### Complete Development Workflow Within Docker Shell

1. **Enter the Docker shell**:
   ```bash
   # From Windows command prompt
   dockrun.bat shell
   ```

2. **Build the code**:
   ```bash
   # Inside Docker shell
   cd /app/docker
   ./build.sh
   ```

3. **Run with graphics (using Xvfb)**:
   ```bash
   # Inside Docker shell
   cd /app/docker
   ./build.sh xvfb
   ```
   Then connect with a VNC client to localhost:5900

4. **Debug mode**:
   ```bash
   # Inside Docker shell
   cd /app/docker
   ./build.sh debug xvfb
   ```

5. **Clean build**:
   ```bash
   # Inside Docker shell
   cd /app/docker
   rm -rf build
   ./build.sh xvfb
   ```

### Docker Container Details

The Docker container includes:
- Ubuntu 22.04 as the base OS
- Essential build tools (CMake, Ninja, GCC, GDB)
- Graphics libraries (GLFW, GLEW, GLM)
- 3D model importing (Assimp)
- Git for version control
- Xvfb and x11vnc for virtual display

<br>
<br>
<br>
<br>

# Troubleshooting

If you encounter the "No CMAKE_CXX_COMPILER could be found" error, make sure you have installed the GCC compiler package:
```bash
pacman -S mingw-w64-ucrt-x86_64-gcc
```
After installing the compiler, clean the `build` directory and reconfigure the project:
```bash
rm -rf build
mkdir build && cd build
cmake -G Ninja ..
```
Then, rebuild the project:
```bash
cmake --build .
```

### Xvfb and VNC Issues

If you encounter issues with Xvfb or VNC:

1. **"Xvfb not found" error**:
   ```bash
   # Inside Docker container
   apt-get update && apt-get install -y xvfb x11-xserver-utils x11vnc
   ```

2. **"XDG_RUNTIME_DIR not set" warning**:
   - This warning is usually harmless, but you can verify the directory exists:
   ```bash
   mkdir -p /tmp/xdg-runtime-dir
   chmod 700 /tmp/xdg-runtime-dir
   export XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
   ```

3. **Cannot connect to VNC**:
   - Verify the port is properly exposed: `docker ps` (look for 5900:5900)
   - Check if x11vnc is running: `ps -ef | grep x11vnc`
   - Try restarting the VNC server: `pkill x11vnc && x11vnc -display :99 -nopw -forever -quiet &`

## Contributing
If you'd like to contribute to the Game-Engine-CPP project, please follow the standard GitHub workflow:
1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Commit your changes
4. Push your branch to your forked repository
5. Open a pull request

We appreciate your contributions!

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.