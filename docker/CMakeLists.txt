# CMakeLists.txt for Game-Engine-CPP project
# Specify minimum CMake version
cmake_minimum_required(VERSION 3.14)

# Project name and language
project(GameEngine VERSION 1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set output directories - modified to include bin directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build)

# Automatically collect all source files from src directory
file(GLOB_RECURSE SOURCES 
    "/app/src/*.cpp"
    "/app/src/*.hpp"
    "/app/tools/*.h"
)

# Check if sources were found
if(NOT SOURCES)
    message(FATAL_ERROR "No source files found. Check the source directory paths.")
endif()

# Debug output - list found source files
message(STATUS "Found sources: ${SOURCES}")

# Add executable target with all collected source files
add_executable(GameEngine ${SOURCES})

# Include directories
target_include_directories(GameEngine PRIVATE
    /app/includes
)

# If you need to link against libraries, add them here
# target_link_libraries(GameEngine PRIVATE
#     library_name
# )

# Set compile options based on compiler
if(MSVC)
    target_compile_options(GameEngine PRIVATE /W4)
else()
    target_compile_options(GameEngine PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Install rules (optional)
install(TARGETS GameEngine
    RUNTIME DESTINATION bin
)

# Enable testing (optional)
# enable_testing()
# add_test(NAME GameEngineTests COMMAND GameEngine)

# Print configuration summary
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
message(STATUS "CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")
message(STATUS "Output path: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")