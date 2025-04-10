## `Welcome to the Game-Engine-CPP project!`

#### This README will guide you through setting up your development environment and building the project using either MSYS2 and CMake or Docker.



<br>

##### `Only use one option per repository`

> **Why only one option?** Due to technical constraints, MSYS2 and Docker cannot be used interchangeably in the same repository instance. 
When one is installed and configured, it may interfere with the other's functionality. This is an intentional design decision to maintain clean development environments.
>
> **Need both environments?** If you want to work with both MSYS2 and Docker:
> 1. Clone the repository twice into separate directories
> 2. Set up MSYS2 in one directory and Docker in the other
> 3. This allows you to work on the same codebase using different build environments
>
<br>


# Option 1: Using MSYS2

### Prerequisites
Before you start, make sure you have the following installed:
- Windows 10 or later
- [MSYS2 x86_64](https://www.msys2.org/) only for Windows

### Setting Up MSYS2
1. After Download, run the installer.
2. Make sure to install MSYS2 to the `C:\` root directory.
3. After installation, open the "MSYS2 UCRT64" terminal from the Start menu.

### Installing Required Packages for MSYS2
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
1. Clone the Game-Engine-CPP repository or download the source code:
   ```bash
   git clone https://github.com/NikitaKonkov/Game-Engine-CPP.git
   ```
2. In the MSYS2 UCRT64 terminal, navigate to the project directory:
   ```bash
   cd [YOUR PATH FOR THE PROJECT]/Game-Engine-CPP
   ```
3. Run the install script:
   ```bash
   ./install.sh
   ```
   "This will take a while and create a `build` directory, configure the project with CMake, and build the `run.sh` executer."
   
### Executing the Project
* Normal Build
   ```bash
   ./run.sh <- "use it after clean run"
   ```
* Debugging with GDB
   To debug the game engine with GDB, run the build script with the `debug` flag:
   ```bash
   ./run.sh debug
   ```
   "This will build the project and launch it with GDB. You can find the manual in [Debug Manual](debugger/debugger_manual.md#interactive-mode) "
* Clean Build
   To perform a clean build, which deletes the old build files and does a fresh build, run the build script with the `clean` flag:
   ```bash
   ./run.sh clean
   ```
   "This will delete the `build` directory, create a new one, configure the project with CMake, and build the executable.
   After the build completes, press any key to launch the game engine normally (without the debugger)."
  
<br>
<br>

# Option 2: Using Docker

### Prerequisites
Before you start, make sure you have the following installed:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Windows or Docker Engine for Linux

### Getting Started with Docker

#### Quick Start with dockrun.bat

We provide a convenient batch script `dockrun.bat` to manage Docker operations:

```cmd
dockrun.bat { build | shell | clean | rebuild | compile }
```

Commands:
- `clean` - Remove Docker image and containers
- `build` - Build the Docker image
- `compile` - Build the project inside Docker
- `shell` - Open an interactive shell in the container
- `rebuild` - Clean and rebuild Docker image



Typical workflow:
```cmd
# Build the container
dockrun.bat/sh build

# Compile the build
dockrun.bat/sh compile

# Open Docker shell for development
dockrun.bat/sh shell
```

### Working in Docker Shell Environment

#### Building and Running the Project

Once inside the Docker shell (after running `dockrun.bat shell`), you can build and run the project:

```bash
# Navigate to the docker directory
cd /app/docker

# Build the project using the provided build script
./build.sh <- [only terminal, no video device, dont use it!]

# Build and run with Xvfb virtual display
./build.sh xvfb

# To build in debug mode
./build.sh debug

# To run the executable directly
cd /app/bin
./GameEngine
```


**NOTE**: Always use the `xvfb` parameter with the build script when running graphical applications inside the Docker container.

### Connecting with VNC to See Graphical Output

You can view your application's graphical output using a VNC client:

1. **Using VNC Viewer**:
   - Install a VNC viewer like [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/), [TightVNC](https://www.tightvnc.com/), or [VNC Viewer for Google Chrome](https://chrome.google.com/webstore/detail/vnc-viewer-for-google-chr/iabmpiboiopbgfabjmgeedhcmjenhbla)
   - Connect to `localhost:5900`
   

2. **Docker Desktop**:
   - In Docker Desktop, select your running container
   - Find port 5900 in the "PORT MAPPING" section
   - Click to open or copy the link
   This will start a virtual X display and VNC server with the following message:
   ```
   ============= VNC CONNECTION INFO =============
   VNC server started on <container-id>:5900
   To connect from Docker host:
     - Use a VNC viewer to connect to: localhost:5900
   
   Connection options:
     1. Docker Desktop: Use the 'PORT' link next to container
     2. VS Code: Click 'PORTS' tab and look for 5900
     3. Command line: Use 'docker port <container_id> 5900'

   Example output:
      The VNC desktop is:      cb7e353684f5:0 <- exclude ":0"
      PORT=5900
   ================================================
   ```
## Docker Container Details
The Docker container includes:
- Ubuntu 22.04 as the base OS
- Essential build tools (CMake, Ninja, GCC, GDB)
- Graphics libraries (GLFW, GLEW, GLM)
- 3D model importing (Assimp)
- Git for version control
- Xvfb for virtual display

<br>
<br>



# Troubleshooting & Settings

### Xvfb Resolution
   * [change Xvfb resolution](\docker\run_with_xvfb.sh)

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

## Author
Nikita Konkov