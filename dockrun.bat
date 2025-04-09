@echo off
SETLOCAL EnableDelayedExpansion

SET IMAGE_NAME=game-engine-cpp
SET CONTAINER_NAME=game-engine-cpp-dev

echo =^> Game Engine Docker Helper

IF "%1"=="" (
    GOTO usage
) ELSE IF "%1"=="build" (
    GOTO build
) ELSE IF "%1"=="run" (
    GOTO run
) ELSE IF "%1"=="debug" (
    GOTO debug
) ELSE IF "%1"=="clean" (
    GOTO clean
) ELSE IF "%1"=="rebuild" (
    GOTO rebuild
) ELSE IF "%1"=="compile" (
    GOTO compile
) ELSE IF "%1"=="shell" (
    GOTO shell
) ELSE (
    GOTO usage
)

:usage
echo Usage: dockrun.bat {build^|run^|debug^|clean^|rebuild^|compile^|direct-run^|shell}
echo.
echo   build      - Build Docker image
echo   run        - Run the application in Docker with build step
echo   debug      - Run the application in debug mode in Docker
echo   clean      - Remove Docker image and containers
echo   rebuild    - Clean and rebuild Docker image
echo   compile    - Build the project inside Docker
echo   shell      - Get a shell inside the Docker container
echo.
GOTO :EOF

:build
echo Building Docker image...
docker build -t %IMAGE_NAME% docker
echo Build complete!
GOTO :EOF

:run
echo Running the application in Docker...
docker run --rm -it ^
  -v "%CD%":/app ^
  %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
GOTO :EOF

:debug
echo Running the application in debug mode in Docker...
docker run --rm -it ^
  -v "%CD%":/app ^
  %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh debug"
GOTO :EOF

:clean
echo Cleaning Docker resources...
docker run --rm -v "%CD%":/app %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh clean" 2>NUL
docker rm -f %CONTAINER_NAME% 2>NUL
docker rmi -f %IMAGE_NAME% 2>NUL
echo Clean complete!
GOTO :EOF

:rebuild
CALL :clean
CALL :build
GOTO :EOF

:compile
echo Compiling the project inside Docker...
docker run --rm -it -v "%CD%":/app %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
GOTO :EOF

:shell
echo Opening a shell inside the Docker container...
docker run --rm -it ^
  -v "%CD%":/app ^
  %IMAGE_NAME% /bin/bash
GOTO :EOF