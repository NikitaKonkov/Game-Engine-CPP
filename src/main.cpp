#include "../include/header.h" // Include the header file for the hello function
#include "class/MyClass.h" // Include the header file

int main(int argc, char const *argv[])
{   
    (void)argc; // Suppress unused parameter warning
    (void)argv; // Suppress unused parameter warning

    MyClass obj(42); // Create an instance of MyClass
    
    std::cout << "Value: " << obj.getValue() << std::endl;
    
    obj.setValue(100);
    std::cout << "New value: " << obj.getValue() << std::endl;

    std::cout << "Hello, World!" << std::endl; // Print a message to the console
    std::cout << "Welcome to the C++ Game Engine" << std::endl; // Print another message
    
    // Initialize SDL
    if (!SDL_Init(SDL_INIT_VIDEO)) {
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