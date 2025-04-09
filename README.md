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
   ./install.sh
   ```
   This will create a `build` directory, configure the project with CMake, and build the executable.
4. After the build completes, press any key to launch the game engine.

### Debugging with GDB
To debug the game engine with GDB, run the build script with the `debug` flag:
```bash
./install.sh debug
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
./install.sh clean
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

# Development cycle
dockrun.bat compile  # Build the project
dockrun.bat direct-run  # Run the executable
```

#### Manual Docker Commands

If you prefer using Docker directly:

**For Windows users**:
```cmd
# Build the Docker image
docker build -t game-engine-cpp .
   
# Run the container with interactive shell
docker run -it --rm -v "%CD%":/app game-engine-cpp bash
   
# Build the project inside the container
cd /app
mkdir -p build && cd build
cmake .. && make
   
# Run the executable
cd /app/bin
./GameEngine
```

**For Linux/macOS users**:
```bash
# Build the Docker image
docker build -t game-engine-cpp .
   
# Run the container with interactive shell
docker run -it --rm -v "$(pwd)":/app game-engine-cpp bash
   
# Build the project inside the container
cd /app
mkdir -p build && cd build
cmake .. && make
   
# Run the executable
cd /app/bin
./GameEngine
```

#### Working in Docker Shell Environment

When using `dockrun.bat shell` to access the container, you can build and run the project directly:

```bash
# Navigate to the docker directory
cd /app/docker

# Build the project using the provided build script
./build.sh

# The build script will:
# 1. Configure the project with CMake
# 2. Build the project using Ninja
# 3. Prompt to run the application

# You can also build with debug options
./build.sh debug

# To run the executable directly
cd /app/docker/bin
./GameEngine
```

The expected build output will show:
- Source files found
- Build configuration (Release/Debug)
- Compiler information 
- Output paths
- Build status

After building, the engine will run and display:
```
Hello, World!
Welcome to the C++ Game Engine
```

### Development Workflow with Docker

1. **Edit code on your host machine** - All changes are automatically visible inside the container
2. **Build the code** - Use `dockrun.bat compile` to build your changes
3. **Run the application** - Use `dockrun.bat direct-run` to test your changes
4. **Debug** - Build in debug mode with `./build.sh debug` inside the container shell

### Docker Container Details

The Docker container includes:
- Ubuntu 22.04 as the base OS
- Essential build tools (CMake, Ninja, GCC, GDB)
- Graphics libraries (GLFW, GLEW, GLM)
- 3D model importing (Assimp)
- Git for version control

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