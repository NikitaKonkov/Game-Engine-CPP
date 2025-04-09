# CMakeLists.txt for Game-Engine-CPP project
# Specify minimum CMake version
cmake_minimum_required(VERSION 3.14)

# Project name and language
project(GameEngine VERSION 0.1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../bin)

# Automatically collect all source files from src directory
file(GLOB_RECURSE SOURCES 
    "${CMAKE_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_SOURCE_DIR}/tools/*.h"
    "${CMAKE_SOURCE_DIR}/src/*.hpp"
)

# Add executable target with all collected source files
add_executable(GameEngine ${SOURCES})

# Include directories
target_include_directories(GameEngine PRIVATE
    ${CMAKE_SOURCE_DIR}/includes
)

# Find SDL3 package
# First try to find it in the system
find_package(SDL3 QUIET)

# If not found in system, try to find it in our libs directory
if(NOT SDL3_FOUND)
    message(STATUS "SDL3 not found in system, looking in local libs directory...")
    set(SDL3_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/sdl3/SDL/build")
    find_package(SDL3 REQUIRED)
endif()

# Find SDL3 DLL
set(SDL3_DLL_PATHS
    "${SDL3_DIR}/SDL3.dll"
    "${SDL3_DIR}/Debug/SDL3.dll"
    "${SDL3_DIR}/Release/SDL3.dll"
)

foreach(SDL3_DLL_PATH ${SDL3_DLL_PATHS})
    if(EXISTS ${SDL3_DLL_PATH})
        set(SDL3_DLL ${SDL3_DLL_PATH})
        break()
    endif()
endforeach()

if(SDL3_DLL)
    message(STATUS "Found SDL3.dll: ${SDL3_DLL}")
    # Copy SDL3.dll to the output directory
    add_custom_command(TARGET GameEngine POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${SDL3_DLL}"
        "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    message(STATUS "SDL3.dll will be copied to the bin directory after build")
else()
    message(WARNING "SDL3.dll not found, application may fail to run")
endif()

# Link SDL3 library
target_link_libraries(GameEngine PRIVATE SDL3::SDL3)

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