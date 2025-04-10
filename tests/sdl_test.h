#ifndef SDL_TEST_H
#define SDL_TEST_H

#include <iostream>
#include <SDL3/SDL.h> // Include the SDL header file for graphics and window management
#include <SDL3/SDL_version.h> // Include the SDL version header file for version macros
void finish(){
    // SDL version check
    std::cout << "SDL version: " << SDL_MAJOR_VERSION << "." << SDL_MINOR_VERSION << std::endl;
    std::cout << "Test finished" << std::endl;
}

#endif // SDL_TEST_H