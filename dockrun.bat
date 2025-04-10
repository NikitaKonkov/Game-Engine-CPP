@echo off
REM Game Engine Docker Helper Script
REM Usage: dockrun.bat {build|run|shell|clean|rebuild|compile|direct-run}

SETLOCAL EnableDelayedExpansion

REM Define colors for terminal output
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "MAGENTA=[95m"
set "CYAN=[96m"
set "WHITE=[97m"
set "RESET=[0m"

REM Project directories
set "PROJECT_DIR=%CD%"
set "DOCKER_DIR=%PROJECT_DIR%\docker"
set "BUILD_DIR=%PROJECT_DIR%\build"
set "BIN_DIR=%PROJECT_DIR%\bin"

REM Docker settings
set "IMAGE_NAME=game-engine-cpp"
set "CONTAINER_NAME=game-engine-dev"

REM Get command argument
set "COMMAND=%1"

echo %CYAN%=^> Game Engine Docker Helper%RESET%

if "%COMMAND%"=="" (
    call :show_help
    exit /b 0
)

if "%COMMAND%"=="help" (
    call :show_help
    exit /b 0
)

if "%COMMAND%"=="build" (
    echo Building Docker image...
    docker build -t %IMAGE_NAME% "%DOCKER_DIR%"
    exit /b %ERRORLEVEL%
)

if "%COMMAND%"=="shell" (
    echo Opening an interactive shell in the Docker container...
    REM Clean build directory before starting shell to prevent CMake cache issues
    call :clean_build_dir
    docker run --rm -it -v "%PROJECT_DIR%:/app" --name %CONTAINER_NAME% %IMAGE_NAME% bash
    exit /b %ERRORLEVEL%
)

if "%COMMAND%"=="clean" (
    echo Cleaning Docker resources...
    docker stop %CONTAINER_NAME% 2>nul
    docker rm %CONTAINER_NAME% 2>nul
    docker rmi %IMAGE_NAME% 2>nul
    call :clean_build_dir
    exit /b 0
)

if "%COMMAND%"=="rebuild" (
    echo Rebuilding Docker image...
    docker stop %CONTAINER_NAME% 2>nul
    docker rm %CONTAINER_NAME% 2>nul
    docker rmi %IMAGE_NAME% 2>nul
    docker build -t %IMAGE_NAME% "%DOCKER_DIR%"
    exit /b %ERRORLEVEL%
)

if "%COMMAND%"=="compile" (
    echo Compiling the project inside Docker...
    
    REM Create output directories if they don't exist
    if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
    
    REM Clean build directory before compiling
    call :clean_build_dir
    
    REM Fix line endings in shell scripts before execution
    echo Converting script line endings for compatibility...
    docker run --rm -v "%PROJECT_DIR%:/app" %IMAGE_NAME% bash -c "find /app/docker -name \"*.sh\" -type f -exec sed -i 's/\r$//' {} \; && chmod +x /app/docker/*.sh"
    
    REM Run the build script in Docker with proper paths
    docker run --rm -v "%PROJECT_DIR%:/app" %IMAGE_NAME% bash -c "cd /app/docker && ./build.sh"
    exit /b %ERRORLEVEL%
)

if "%COMMAND%"=="run" (
    echo Building and running the application...
    
    REM Check if the Docker image exists, if not build it
    docker image inspect %IMAGE_NAME% >nul 2>&1
    if !ERRORLEVEL! neq 0 (
        echo Docker image not found. Building it first...
        docker build -t %IMAGE_NAME% "%DOCKER_DIR%"
    )
    
    REM Clean build directory before running
    call :clean_build_dir
    
    REM Fix line endings before running
    docker run --rm -v "%PROJECT_DIR%:/app" %IMAGE_NAME% bash -c "find /app/docker -name \"*.sh\" -type f -exec sed -i 's/\r$//' {} \; && chmod +x /app/docker/*.sh"
    
    REM Compile and run
    docker run --rm -v "%PROJECT_DIR%:/app" %IMAGE_NAME% bash -c "cd /app/docker && ./build.sh"
    exit /b %ERRORLEVEL%
)

if "%COMMAND%"=="direct-run" (
    echo Running the application directly without build...
    
    REM Check if the binary exists
    if not exist "%BIN_DIR%\GameEngine.exe" (
        echo Error: GameEngine executable not found in the bin directory.
        echo Build the project first using: dockrun.bat compile
        exit /b 1
    )
    
    "%BIN_DIR%\GameEngine.exe"
    exit /b %ERRORLEVEL%
)

echo %YELLOW%Unknown command: %COMMAND%%RESET%
call :show_help
exit /b 1

:show_help
echo %GREEN%Usage: dockrun.bat {command}%RESET%
echo.
echo Available commands:
echo   %CYAN%build%RESET%       - Build the Docker image
echo   %CYAN%run%RESET%         - Build and run the application
echo   %CYAN%shell%RESET%       - Open an interactive shell in the container
echo   %CYAN%clean%RESET%       - Remove Docker image and containers
echo   %CYAN%rebuild%RESET%     - Clean and rebuild Docker image
echo   %CYAN%compile%RESET%     - Build the project inside Docker
echo   %CYAN%direct-run%RESET%  - Directly run the executable without build
echo.
exit /b 0

:clean_build_dir
echo %YELLOW%Cleaning build directory to avoid CMake cache conflicts...%RESET%
if exist "%BUILD_DIR%" (
    rmdir /S /Q "%BUILD_DIR%"
)
mkdir "%BUILD_DIR%"
echo %GREEN%Build directory cleaned.%RESET%
exit /b 0