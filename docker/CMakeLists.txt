# CMakeLists.txt for Game-Engine-CPP project in Docker environment
# Specify minimum CMake version
cmake_minimum_required(VERSION 3.14)

# Project name and language
project(GameEngine VERSION 1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add path to our custom CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/docker/cmake")

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../bin)

# Debug output
message(STATUS "PROJECT_SOURCE_DIR: ${PROJECT_SOURCE_DIR}")
message(STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")

# Automatically collect all source files from src directory
file(GLOB_RECURSE SOURCES 
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/tools/*.h"
)

# Check if sources were found
if(NOT SOURCES)
    message(FATAL_ERROR "No source files found. Check the source directory paths: ${CMAKE_CURRENT_SOURCE_DIR}/src")
endif()

# Debug output - list found source files
message(STATUS "Found sources: ${SOURCES}")

# Add executable target with all collected source files
add_executable(GameEngine ${SOURCES})

# Include directories
target_include_directories(GameEngine PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/includes
)

# Find SDL3 package using our custom finder module
find_package(SDL3 REQUIRED)
message(STATUS "SDL3_FOUND: ${SDL3_FOUND}")
message(STATUS "SDL3_INCLUDE_DIRS: ${SDL3_INCLUDE_DIRS}")
message(STATUS "SDL3_LIBRARIES: ${SDL3_LIBRARIES}")

# Link SDL3 properly regardless of how it's found
if(TARGET SDL3::SDL3)
    message(STATUS "Found SDL3 target, linking directly")
    target_link_libraries(GameEngine PRIVATE SDL3::SDL3)
else()
    message(STATUS "Linking SDL3 through include/link directories")
    target_include_directories(GameEngine PRIVATE ${SDL3_INCLUDE_DIRS})
    target_link_libraries(GameEngine PRIVATE ${SDL3_LIBRARIES})
endif()

# Set compile options based on compiler
if(MSVC)
    target_compile_options(GameEngine PRIVATE /W4)
else()
    target_compile_options(GameEngine PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Install rules
install(TARGETS GameEngine
    RUNTIME DESTINATION bin
)

# Print configuration summary
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
message(STATUS "CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")
message(STATUS "Output path: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")