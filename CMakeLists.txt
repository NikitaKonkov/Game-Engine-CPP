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

# If not found in system, try multiple possible directory locations
if(NOT SDL3_FOUND)
    message(STATUS "SDL3 not found in system, looking in local libs directory...")
    
    # List of possible locations for SDL3
    set(SDL3_POSSIBLE_PATHS
        "${CMAKE_CURRENT_SOURCE_DIR}/libs/sdl3/SDL/build"
        "${CMAKE_CURRENT_SOURCE_DIR}/../libs/sdl3/SDL/build"
        "${CMAKE_CURRENT_SOURCE_DIR}/libs/sdl3/build"
        "${CMAKE_CURRENT_SOURCE_DIR}/../libs/sdl3/build"
    )
    
    # Try each location
    foreach(SDL3_PATH ${SDL3_POSSIBLE_PATHS})
        if(EXISTS "${SDL3_PATH}/SDL3Config.cmake")
            message(STATUS "Found SDL3 at: ${SDL3_PATH}")
            set(SDL3_DIR "${SDL3_PATH}")
            find_package(SDL3 QUIET)
            if(SDL3_FOUND)
                break()
            endif()
        endif()
    endforeach()
    
    # If SDL3 is still not found, build it
    if(NOT SDL3_FOUND)
        message(STATUS "SDL3 not found in standard locations, attempting to build it...")
        
        # Define SDL3 source directory
        set(SDL3_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/sdl3/SDL")
        set(SDL3_BUILD_DIR "${SDL3_SOURCE_DIR}/build")
        
        # Check if SDL3 source exists
        if(NOT EXISTS "${SDL3_SOURCE_DIR}/CMakeLists.txt")
            message(STATUS "SDL3 source not found, cloning from repository...")
            
            # Create directory if it doesn't exist
            file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/libs/sdl3")
            
            # Clone SDL3 repository
            find_package(Git REQUIRED)
            execute_process(
                COMMAND ${GIT_EXECUTABLE} clone https://github.com/libsdl-org/SDL.git "${SDL3_SOURCE_DIR}"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/libs/sdl3"
                RESULT_VARIABLE GIT_RESULT
            )
            
            if(NOT GIT_RESULT EQUAL 0)
                message(FATAL_ERROR "Failed to clone SDL3 repository")
            endif()
        endif()
        
        # Configure and build SDL3
        message(STATUS "Building SDL3 from source at ${SDL3_SOURCE_DIR}...")
        file(MAKE_DIRECTORY "${SDL3_BUILD_DIR}")
        
        execute_process(
            COMMAND ${CMAKE_COMMAND} 
                -G Ninja
                -DCMAKE_BUILD_TYPE=Release 
                -DBUILD_SHARED_LIBS=ON
                -DSDL_SHARED=ON
                -DSDL_STATIC=OFF
                -DSDL_TEST=OFF
                ..
            WORKING_DIRECTORY "${SDL3_BUILD_DIR}"
            RESULT_VARIABLE CMAKE_RESULT
        )
        
        if(NOT CMAKE_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to configure SDL3")
        endif()
        
        execute_process(
            COMMAND ${CMAKE_COMMAND} --build . --config Release
            WORKING_DIRECTORY "${SDL3_BUILD_DIR}"
            RESULT_VARIABLE BUILD_RESULT
        )
        
        if(NOT BUILD_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to build SDL3")
        endif()
        
        # Set the SDL3_DIR to the build directory and try to find SDL3 again
        set(SDL3_DIR "${SDL3_BUILD_DIR}")
        find_package(SDL3 REQUIRED)
    endif()
endif()

# Fix the SDL3 import library finding issue
# This code should be added right after SDL3 is found or built

# Check if SDL3 was found but the library file is missing
if(SDL3_FOUND)
    # Get the imported location of SDL3::SDL3
    get_target_property(SDL3_LIBRARY SDL3::SDL3 IMPORTED_LOCATION)
    get_target_property(SDL3_IMPLIB SDL3::SDL3 IMPORTED_IMPLIB)
    
    message(STATUS "SDL3 Import Library: ${SDL3_IMPLIB}")
    message(STATUS "SDL3 Library: ${SDL3_LIBRARY}")
    
    # If the import library doesn't exist, we need to fix it
    if((NOT SDL3_IMPLIB OR NOT EXISTS "${SDL3_IMPLIB}") AND SDL3_DIR)
        message(STATUS "SDL3 import library not found or incorrect, searching alternatives...")
        
        # Search for possible import library names in SDL3_DIR
        set(POSSIBLE_SDL3_IMPLIBS
            "${SDL3_DIR}/libSDL3.dll.a"
            "${SDL3_DIR}/libSDL3.a"
            "${SDL3_DIR}/SDL3.lib"
            "${SDL3_DIR}/SDL3.dll.a"
            "${SDL3_DIR}/Release/libSDL3.dll.a"
            "${SDL3_DIR}/Release/libSDL3.a"
            "${SDL3_DIR}/Release/SDL3.lib"
            "${SDL3_DIR}/../libSDL3.dll.a"
            "${SDL3_DIR}/../libSDL3.a"
            "${SDL3_DIR}/../SDL3.lib"
        )
        
        # Check each possibility
        foreach(IMPLIB ${POSSIBLE_SDL3_IMPLIBS})
            if(EXISTS "${IMPLIB}")
                message(STATUS "Found alternative SDL3 import library: ${IMPLIB}")
                
                # Create our own SDL3 target to use the correct library
                if(NOT TARGET SDL3_Found)
                    add_library(SDL3_Found SHARED IMPORTED)
                    set_target_properties(SDL3_Found PROPERTIES
                        IMPORTED_IMPLIB "${IMPLIB}"
                        IMPORTED_LOCATION "${SDL3_LIBRARY}"
                        INTERFACE_INCLUDE_DIRECTORIES "${SDL3_DIR}/../include"
                    )
                    
                    # Change target_link_libraries to use our corrected target instead
                    message(STATUS "Using custom SDL3 import library for linking")
                    set(SDL3_LIBRARIES SDL3_Found)
                    break()
                endif()
            endif()
        endforeach() # Make sure this endforeach() is here
        
        # If still not found, try using file(GLOB...) to find import libraries
        if(NOT TARGET SDL3_Found)
            file(GLOB_RECURSE SDL3_IMPLIB_FILES
                "${CMAKE_CURRENT_SOURCE_DIR}/libs/**/*SDL3*.a"
                "${CMAKE_CURRENT_SOURCE_DIR}/libs/**/*SDL3*.lib"
            )
            
            if(SDL3_IMPLIB_FILES)
                list(GET SDL3_IMPLIB_FILES 0 FOUND_IMPLIB)
                message(STATUS "Found SDL3 import library via glob: ${FOUND_IMPLIB}")
                
                add_library(SDL3_Found SHARED IMPORTED)
                set_target_properties(SDL3_Found PROPERTIES
                    IMPORTED_IMPLIB "${FOUND_IMPLIB}"
                    IMPORTED_LOCATION "${SDL3_LIBRARY}"
                    INTERFACE_INCLUDE_DIRECTORIES "${SDL3_DIR}/../include"
                )
                
                set(SDL3_LIBRARIES SDL3_Found)
            endif()
        endif()
    endif() # Make sure this endif() is here
endif()

# If we have a custom SDL3 target, use that instead
if(TARGET SDL3_Found)
    message(STATUS "Using custom SDL3 target for linking")
    target_link_libraries(GameEngine PRIVATE ${SDL3_LIBRARIES})
else()
    # Otherwise use the standard target
    message(STATUS "Using standard SDL3::SDL3 target for linking")
    target_link_libraries(GameEngine PRIVATE SDL3::SDL3)
endif()

# Enhanced SDL3 DLL finder
set(SDL3_DLL_FOUND FALSE)
set(SDL3_DLL_PATHS
    "${SDL3_DIR}/SDL3.dll"
    "${SDL3_DIR}/Debug/SDL3.dll"
    "${SDL3_DIR}/Release/SDL3.dll"
    "${SDL3_SOURCE_DIR}/build/SDL3.dll"
    "${SDL3_SOURCE_DIR}/build/Debug/SDL3.dll"
    "${SDL3_SOURCE_DIR}/build/Release/SDL3.dll"
)

# Use file(GLOB...) to find SDL3 DLL recursively if not found in standard locations
file(GLOB_RECURSE SDL3_DLL_FILES 
    "${CMAKE_CURRENT_SOURCE_DIR}/libs/**/SDL3.dll"
    "${CMAKE_CURRENT_SOURCE_DIR}/../libs/**/SDL3.dll"
)

if(SDL3_DLL_FILES)
    list(APPEND SDL3_DLL_PATHS ${SDL3_DLL_FILES})
endif()

foreach(SDL3_DLL_PATH ${SDL3_DLL_PATHS})
    if(EXISTS ${SDL3_DLL_PATH})
        set(SDL3_DLL ${SDL3_DLL_PATH})
        set(SDL3_DLL_FOUND TRUE)
        message(STATUS "Found SDL3.dll: ${SDL3_DLL}")
        break()
    endif()
endforeach()

if(SDL3_DLL_FOUND)
    # Copy SDL3.dll to the output directory
    add_custom_command(TARGET GameEngine POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${SDL3_DLL}"
        "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    message(STATUS "SDL3.dll will be copied to the bin directory after build")
else()
    message(WARNING "SDL3.dll not found, application may fail to run")
endif()

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