@echo off
SETLOCAL EnableDelayedExpansion

SET IMAGE_NAME=game-engine-cpp
SET CONTAINER_NAME=game-engine-cpp-dev

echo [94m=^> Game Engine Docker Helper[0m

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
) ELSE IF "%1"=="direct-run" (
    GOTO direct-run
) ELSE IF "%1"=="shell" (
    GOTO shell
) ELSE (
    GOTO usage
)

:usage
echo [93mUsage: dockrun.bat {build^|run^|debug^|clean^|rebuild^|compile^|direct-run^|shell}[0m
echo.
echo   [96mbuild[0m      - Build Docker image
echo   [96mrun[0m        - Run the application in Docker with build step
echo   [96mdebug[0m      - Run the application in debug mode in Docker
echo   [96mclean[0m      - Remove Docker image and containers
echo   [96mrebuild[0m    - Clean and rebuild Docker image
echo   [96mcompile[0m    - Build the project inside Docker
echo   [96mdirect-run[0m - Directly run the executable without build or prompt
echo   [96mshell[0m      - Get a shell inside the Docker container
echo.
GOTO :EOF

:build
echo [94mBuilding Docker image...[0m
docker build -t %IMAGE_NAME% docker
echo [92mBuild complete![0m
GOTO :EOF

:run
echo [94mRunning the application in Docker...[0m
docker run --rm -it ^
  -v "%CD%":/app ^
  %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
GOTO :EOF

:debug
echo [94mRunning the application in debug mode in Docker...[0m
docker run --rm -it ^
  -v "%CD%":/app ^
  %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh debug"
GOTO :EOF

:clean
echo [94mCleaning Docker resources...[0m
docker run --rm -v "%CD%":/app %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh clean" 2>NUL
docker rm -f %CONTAINER_NAME% 2>NUL
docker rmi -f %IMAGE_NAME% 2>NUL
echo [92mClean complete![0m
GOTO :EOF

:rebuild
CALL :clean
CALL :build
GOTO :EOF

:compile
echo [94mCompiling the project inside Docker...[0m
docker run --rm -it -v "%CD%":/app %IMAGE_NAME% /bin/bash -c "cd /app && chmod +x /app/docker/build.sh && /app/docker/build.sh"
GOTO :EOF

:direct-run
echo [94mDirectly running the executable...[0m
docker run --rm -it ^
  -v "%CD%":/app ^
  %IMAGE_NAME% /bin/bash -c "cd /app/bin && if exist GameEngine (./GameEngine) else (echo [91mExecutable not found[0m)"
GOTO :EOF

:shell
echo [94mOpening a shell inside the Docker container...[0m
docker run --rm -it ^
  -v "%CD%":/app ^
  %IMAGE_NAME% /bin/bash
GOTO :EOF