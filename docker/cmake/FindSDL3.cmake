# FindSDL3.cmake
# Custom finder script for SDL3
#
# This module defines:
#  SDL3_FOUND - if SDL3 was found
#  SDL3_INCLUDE_DIRS - SDL3 include directories
#  SDL3_LIBRARIES - SDL3 libraries to link
#  SDL3::SDL3 - imported target for SDL3 (if supported by CMake version)

# Try to find SDL3 using pkg-config
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_SDL3 QUIET sdl3)
endif()

# Find include directory
find_path(SDL3_INCLUDE_DIR
  NAMES SDL3/SDL.h
  HINTS
    ${PC_SDL3_INCLUDEDIR}
    ${PC_SDL3_INCLUDE_DIRS}
    /usr/local/include
    /usr/include
)

# Find library
find_library(SDL3_LIBRARY
  NAMES SDL3 libSDL3
  HINTS
    ${PC_SDL3_LIBDIR}
    ${PC_SDL3_LIBRARY_DIRS}
    /usr/local/lib
    /usr/local/lib64
    /usr/lib
    /usr/lib64
)

# Handle the QUIETLY and REQUIRED arguments and set SDL3_FOUND
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SDL3
  REQUIRED_VARS SDL3_LIBRARY SDL3_INCLUDE_DIR
)

# Set output variables
if(SDL3_FOUND)
  set(SDL3_LIBRARIES ${SDL3_LIBRARY})
  set(SDL3_INCLUDE_DIRS ${SDL3_INCLUDE_DIR})
  
  # Create imported target if not already created and if supported by CMake version
  if(NOT TARGET SDL3::SDL3 AND CMAKE_VERSION VERSION_GREATER_EQUAL "3.0.0")
    add_library(SDL3::SDL3 UNKNOWN IMPORTED)
    set_target_properties(SDL3::SDL3 PROPERTIES
      IMPORTED_LOCATION "${SDL3_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${SDL3_INCLUDE_DIR}"
    )
  endif()
endif()

# Show debug info
mark_as_advanced(SDL3_INCLUDE_DIR SDL3_LIBRARY)
message(STATUS "SDL3_FOUND: ${SDL3_FOUND}")
message(STATUS "SDL3_INCLUDE_DIRS: ${SDL3_INCLUDE_DIRS}")
message(STATUS "SDL3_LIBRARIES: ${SDL3_LIBRARIES}")