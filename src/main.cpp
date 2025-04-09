#include "../include/header.h" // Include the header file for the hello function
#include "../tools/compiler_integrity.h" // Include the integrity header file for the RuleOfThree class
#include "../tools/datafile_integrity.h" // Include the datafile integrity header file for file operations
#include <SDL3/SDL.h> // Include the SDL header file for graphics and window management
#include <string.h>
#include <iostream>

int main(int argc, char const *argv[])
{   
    // Debug message at start
    std::cout << "Program started with " << argc << " argument(s)" << std::endl;
    
    // Print all received arguments
    for (int i = 0; i < argc; ++i) {
        std::cout << "Argument " << i << ": " << argv[i] << std::endl;
    }
    
    // run the test functions if the program is run as debug
    if (argc > 1 && strcmp(argv[1], "debug") == 0) {
        std::cout << "Debug mode detected, running tests..." << std::endl;
        
        int check = test_a(); // Call the test function from the integrity header
        std::cout << "Test A returned: " << check << std::endl;
        if (check != 0) { // Check if the test function returned an error code
            std::cerr << "Test 1 failed with error code: " << check << std::endl; // Print the error code
            return check; // Return the error code
        } else {
            std::cout << "Test 1 passed successfully" << std::endl;
        }
        
        int check_b = test_b(); // Call the test function from the datafile integrity header
        std::cout << "Test B returned: " << check_b << std::endl;
        if (check_b != 0) { // Check if the test function returned an error code
            std::cerr << "Test 2 failed with error code: " << check_b << std::endl; // Print the error code
            return check_b; // Return the error code
        } else {
            std::cout << "Test 2 passed successfully" << std::endl;
        }
        
        std::cout << "All tests completed successfully" << std::endl;
    } else {
        std::cout << "Running in normal mode (use 'debug' argument to run tests)" << std::endl;
    }

    std::cout << "Hello, World!" << std::endl; // Print a message to the console
    std::cout << "Welcome to the C++ Game Engine" << std::endl; // Print another message
    
    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return -1;
    }

    // Create window - SDL3 changed the window creation syntax
    SDL_Window* window = SDL_CreateWindow("Game Engine - SDL3 Window", 800, 600, 0);
    if (!window) {
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return -1;
    }

    // Create renderer - SDL3 doesn't use the same flags as SDL2
    // Just passing 0 for default flags which gives hardware acceleration
    SDL_Renderer* renderer = SDL_CreateRenderer(window, NULL);
    if (!renderer) {
        std::cerr << "Renderer could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    // Main loop flag
    bool quit = false;

    // Event handler
    SDL_Event e;

    // Main loop
    while (!quit) {
        // Handle events on queue
        while (SDL_PollEvent(&e) != 0) {
            // User requests quit
            if (e.type == SDL_EVENT_QUIT) {
                quit = true;
            }
            // Handle key presses - SDL3 changed the event structure
            else if (e.type == SDL_EVENT_KEY_DOWN) {
                // In SDL3, we access the scancode from the key event directly
                SDL_Scancode scancode = e.key.scancode;
                if (scancode == SDL_SCANCODE_ESCAPE) {
                    quit = true;
                }
            }
        }

        // Clear screen
        SDL_SetRenderDrawColor(renderer, 0x20, 0x20, 0x40, 0xFF);
        SDL_RenderClear(renderer);

        // Draw a rectangle in the middle of the screen
        SDL_FRect rect = {300.0f, 200.0f, 200.0f, 200.0f};
        SDL_SetRenderDrawColor(renderer, 0xFF, 0x80, 0x40, 0xFF);
        SDL_RenderFillRect(renderer, &rect);

        // Update screen
        SDL_RenderPresent(renderer);

        // Small delay to avoid maxing out CPU
        SDL_Delay(16); // ~60 fps
    }

    // Clean up
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}