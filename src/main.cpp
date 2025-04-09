#include "../include/header.h" // Include the header file for the hello function
#include "../tools/compiler_integrity.h" // Include the integrity header file for the RuleOfThree class
#include "../tools/datafile_integrity.h" // Include the datafile integrity header file for file operations
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
    // std::cout << number <<std::endl; // Print another message
    // // Your code here

    // std::string text; // Declare a string variable
    // std::cout << "Enter an integer: "; // Prompt the user for input
    // std::cin >> text; // Read an integer from the user
    // std::cout << "You entered: " << text << std::endl; // Print the entered integer

    return 0;
}