# CMakeLists.txt for Game-Engine-CPP project
# Specify minimum CMake version
cmake_minimum_required(VERSION 3.14)

# Project name and language
project(GameEngine VERSION 0.1.0 LANGUAGES CXX)

# Add near the top of your main CMakeLists.txt, after the project() call
enable_testing()

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Force the Ninja generator to avoid mismatches
if(NOT CMAKE_GENERATOR STREQUAL "Ninja")
  message(STATUS "Regenerating with Ninja...")
  set(CLEAN_BUILD_DIR "${CMAKE_BINARY_DIR}")
  execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CLEAN_BUILD_DIR})
  execute_process(
    COMMAND ${CMAKE_COMMAND} -G Ninja ${CMAKE_SOURCE_DIR}
  )

  # return()
endif()

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

# Create a library with your engine code (all sources except main.cpp)
file(GLOB_RECURSE LIB_SOURCES 
    "${CMAKE_SOURCE_DIR}/src/audio/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/editor/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/input/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/output/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/renderer/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/shader/*.cpp"
)
add_library(GameEngineLib SHARED ${LIB_SOURCES})

# Create your main executable with just the main file
add_executable(GameEngine src/main.cpp)

# Link the executable to the library
target_link_libraries(GameEngine PRIVATE GameEngineLib)

# Also link SDL3 directly to the executable since it calls SDL functions
if(TARGET SDL3_Found)
    target_link_libraries(GameEngine PRIVATE ${SDL3_LIBRARIES})
else()
    target_link_libraries(GameEngine PRIVATE SDL3::SDL3)
endif()

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
    target_link_libraries(GameEngineLib PRIVATE ${SDL3_LIBRARIES})
else()
    # Otherwise use the standard target
    message(STATUS "Using standard SDL3::SDL3 target for linking")
    target_link_libraries(GameEngineLib PRIVATE SDL3::SDL3)
endif()

# Find SDL3 include directory - add this after you find SDL3
if(SDL3_FOUND)
    # Get SDL3 include directories
    get_target_property(SDL3_INCLUDE_DIRS SDL3::SDL3 INTERFACE_INCLUDE_DIRECTORIES)
    message(STATUS "SDL3 include directories: ${SDL3_INCLUDE_DIRS}")
endif()

# If using custom SDL3 target
if(TARGET SDL3_Found)
    # Set include directories for the custom target
    if(EXISTS "${SDL3_DIR}/../include")
        set_target_properties(SDL3_Found PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${SDL3_DIR}/../include")
        set(SDL3_INCLUDE_DIRS "${SDL3_DIR}/../include")
    endif()
endif()

# Add SDL3 include directories to your targets
target_include_directories(GameEngineLib PUBLIC ${SDL3_INCLUDE_DIRS})
target_include_directories(GameEngine PUBLIC ${SDL3_INCLUDE_DIRS})

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

# Add this before trying to link to GameEngine
set_target_properties(GameEngine PROPERTIES ENABLE_EXPORTS ON)

# Install rules (optional)
install(TARGETS GameEngine
    RUNTIME DESTINATION bin
)

# Enable testing (optional)
# enable_testing()
# add_test(NAME GameEngineTests COMMAND GameEngine)

# Example for adding a test
add_executable(my_test tests/my_test.cpp)
target_link_libraries(my_test PRIVATE GameEngineLib) # Link to your main library

# Register with CTest
add_test(NAME MyTest COMMAND my_test)

# Print configuration summary
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
message(STATUS "CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")