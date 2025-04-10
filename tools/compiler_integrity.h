#ifndef INTEGRITY_H
#define INTEGRITY_H
#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <utility>
#include <cassert> // For assertions in tests
#include <thread>
#include <chrono>
#include <atomic>
#include <stdexcept> // For exception handling
#include <type_traits> // For std::is_trivially_copyable, std::is_trivially_destructible, etc.
#include <algorithm> // For std::copy, std::move
#include <iterator> // For std::begin, std::end
#include <initializer_list> // For std::initializer_list
#include <cstddef> // For std::size_t
#include <cstdint> // For std::uintptr_t
#include <cstdlib> // For std::malloc, std::free
#include <new>      // For placement new

// ===== Rule of Three Implementation =====
class RuleOfThree {
private:
    int* data;
    size_t size;
    
public:
    // Constructor
    RuleOfThree(size_t n = 0) : size(n) {
        // std::cout << "RuleOfThree: Constructor called\n";
        data = (n > 0) ? new int[n]() : nullptr;
    }
    
    // Destructor
    ~RuleOfThree() {
        // std::cout << "RuleOfThree: Destructor called\n";
        delete[] data;
    }
    
    // Copy constructor
    RuleOfThree(const RuleOfThree& other) : size(other.size) {
        // std::cout << "RuleOfThree: Copy constructor called\n";
        data = (size > 0) ? new int[size]() : nullptr;
        for (size_t i = 0; i < size; ++i) {
            data[i] = other.data[i];
        }
    }
    
    // Copy assignment operator
    RuleOfThree& operator=(const RuleOfThree& other) {
        // std::cout << "RuleOfThree: Copy assignment called\n";
        if (this != &other) {
            delete[] data;
            size = other.size;
            data = (size > 0) ? new int[size]() : nullptr;
            for (size_t i = 0; i < size; ++i) {
                data[i] = other.data[i];
            }
        }
        return *this;
    }
    
    // Utility function to set values
    void setValue(size_t index, int value) {
        if (index < size) {
            data[index] = value;
        }
    }
    
    // Utility function to get values
    int getValue(size_t index) const {
        return (index < size) ? data[index] : -1;
    }
    
    size_t getSize() const { return size; }
};

// ===== Rule of Five Implementation =====
class RuleOfFive {
private:
    int* data;
    size_t size;
    
public:
    // Constructor
    RuleOfFive(size_t n = 0) : size(n) {
        // std::cout << "RuleOfFive: Constructor called\n";
        data = (n > 0) ? new int[n]() : nullptr;
    }
    
    // Destructor
    ~RuleOfFive() {
        // std::cout << "RuleOfFive: Destructor called\n";
        delete[] data;
    }
    
    // Copy constructor
    RuleOfFive(const RuleOfFive& other) : size(other.size) {
        // std::cout << "RuleOfFive: Copy constructor called\n";
        data = (size > 0) ? new int[size]() : nullptr;
        for (size_t i = 0; i < size; ++i) {
            data[i] = other.data[i];
        }
    }
    
    // Copy assignment operator
    RuleOfFive& operator=(const RuleOfFive& other) {
        // std::cout << "RuleOfFive: Copy assignment called\n";
        if (this != &other) {
            delete[] data;
            size = other.size;
            data = (size > 0) ? new int[size]() : nullptr;
            for (size_t i = 0; i < size; ++i) {
                data[i] = other.data[i];
            }
        }
        return *this;
    }
    
    // Move constructor
    RuleOfFive(RuleOfFive&& other) noexcept : data(other.data), size(other.size) {
        // std::cout << "RuleOfFive: Move constructor called\n";
        other.data = nullptr;
        other.size = 0;
    }
    
    // Move assignment operator
    RuleOfFive& operator=(RuleOfFive&& other) noexcept {
        // std::cout << "RuleOfFive: Move assignment called\n";
        if (this != &other) {
            delete[] data;
            data = other.data;
            size = other.size;
            other.data = nullptr;
            other.size = 0;
        }
        return *this;
    }
    
    // Utility function to set values
    void setValue(size_t index, int value) {
        if (index < size) {
            data[index] = value;
        }
    }
    
    // Utility function to get values
    int getValue(size_t index) const {
        return (index < size) ? data[index] : -1;
    }
    
    size_t getSize() const { return size; }
};

// ===== Rule of Zero Implementation =====
class RuleOfZero {
private:
    std::vector<int> data;
    
public:
    // Constructor
    RuleOfZero(size_t n = 0) : data(n) {
        // std::cout << "RuleOfZero: Constructor called\n";
    }
    
    // No need to define destructor, copy/move constructors, or assignment operators
    // The compiler will generate them correctly based on std::vector
    
    // Utility function to set values
    void setValue(size_t index, int value) {
        if (index < data.size()) {
            data[index] = value;
        }
    }
    
    // Utility function to get values
    int getValue(size_t index) const {
        return (index < data.size()) ? data[index] : -1;
    }
    
    size_t getSize() const { return data.size(); }
};

// ===== Test Functions =====
void testRuleOfThree() {
    // std::cout << "\n===== Testing Rule of Three =====\n";
    
    // Test construction
    RuleOfThree obj1(5);
    for (size_t i = 0; i < obj1.getSize(); ++i) {
        obj1.setValue(i, static_cast<int>(i * 10));
    }
    
    // Test copy construction
    RuleOfThree obj2 = obj1;
    // Add assertions to verify correct behavior
    assert(obj2.getSize() == obj1.getSize());
    for (size_t i = 0; i < obj2.getSize(); ++i) {
        assert(obj2.getValue(i) == obj1.getValue(i));
    }
    // std::cout << "\n";
    
    // Test copy assignment
    RuleOfThree obj3(2);
    obj3 = obj1;
    // std::cout << "After copy assignment, obj3 values: ";
    for (size_t i = 0; i < obj3.getSize(); ++i) {
        // std::cout << obj3.getValue(i) << " ";
    }
    // std::cout << "\n";
    
    // Modify original to prove deep copy
    obj1.setValue(0, 999);
    assert(obj2.getValue(0) != 999);
    // std::cout << "After modifying obj1, obj2[0] = " << obj2.getValue(0) << ", obj3[0] = " << obj3.getValue(0) << "\n";
    
    // Objects will be destroyed when function ends
}

void testRuleOfFive() {
    // std::cout << "\n===== Testing Rule of Five =====\n";
    
    // Test construction
    RuleOfFive obj1(5);
    for (size_t i = 0; i < obj1.getSize(); ++i) {
        obj1.setValue(i, static_cast<int>(i * 10));
    }
    
    // Test copy construction
    RuleOfFive obj2 = obj1;
    // std::cout << "After copy construction, obj2 values: ";
    for (size_t i = 0; i < obj2.getSize(); ++i) {
        // std::cout << obj2.getValue(i) << " ";
    }
    // std::cout << "\n";
    
    // Test move construction - create a named temporary and move it
    RuleOfFive temp1(obj1);
    RuleOfFive obj3 = std::move(temp1);
    // std::cout << "After move construction, obj3 values: ";
    for (size_t i = 0; i < obj3.getSize(); ++i) {
        // std::cout << obj3.getValue(i) << " ";
    }
    // std::cout << "\n";
    
    // Test move assignment - create a named temporary and move it
    RuleOfFive temp2(obj1);
    RuleOfFive obj4;
    obj4 = std::move(temp2);
    // std::cout << "After move assignment, obj4 values: ";
    for (size_t i = 0; i < obj4.getSize(); ++i) {
        // std::cout << obj4.getValue(i) << " ";
    }
    // std::cout << "\n";
    
    // Verify that moved-from objects are in valid but unspecified state
    // std::cout << "Moved-from temp1 size: " << temp1.getSize() << "\n";
    // std::cout << "Moved-from temp2 size: " << temp2.getSize() << "\n";
    
    // Modify original to prove deep copy
    obj1.setValue(0, 999);
    // std::cout << "After modifying obj1, obj2[0] = " << obj2.getValue(0) << "\n";
    
    // Objects will be destroyed when function ends
}

void testRuleOfZero() {
    // std::cout << "\n===== Testing Rule of Zero =====\n";
    
    // Test construction
    RuleOfZero obj1(5);
    for (size_t i = 0; i < obj1.getSize(); ++i) {
        obj1.setValue(i, static_cast<int>(i * 10));
    }
    
    // Test copy construction
    RuleOfZero obj2 = obj1;
    // std::cout << "After copy construction, obj2 values: ";
    for (size_t i = 0; i < obj2.getSize(); ++i) {
        // std::cout << obj2.getValue(i) << " ";
    }
    // std::cout << "\n";
    
    // Test move construction - create a named temporary and move it
    RuleOfZero temp1(obj1);
    RuleOfZero obj3 = std::move(temp1);
    // std::cout << "After move construction, obj3 values: ";
    for (size_t i = 0; i < obj3.getSize(); ++i) {
        // std::cout << obj3.getValue(i) << " ";
    }
    // std::cout << "\n";
    
    // Test move assignment - create a named temporary and move it
    RuleOfZero temp2(obj1);
    RuleOfZero obj4;
    obj4 = std::move(temp2);
    // std::cout << "After move assignment, obj4 values: ";
    for (size_t i = 0; i < obj4.getSize(); ++i) {
        // std::cout << obj4.getValue(i) << " ";
    }
    // std::cout << "\n";
    
    // Modify original to prove deep copy
    obj1.setValue(0, 999);
    // std::cout << "After modifying obj1, obj2[0] = " << obj2.getValue(0) << "\n";
    
    // Objects will be destroyed when function ends
}
void testExceptionSafety() {
    // std::cout << "\n===== Testing Exception Safety =====\n";
    
    // Setup a class that throws during copy
    class ThrowOnCopy {
    public:
        ThrowOnCopy() = default;
        ThrowOnCopy(const ThrowOnCopy&) {
            throw std::runtime_error("Copy constructor threw");
        }
    };
    
    // Test that resources are properly cleaned up when exceptions occur
    try {
        RuleOfFive obj(5);
        obj.setValue(0, 100);
        
        // This should throw during vector's internal copy
        std::vector<ThrowOnCopy> v(1);
        v.resize(10); // Should throw
        
        // std::cout << "Error: Exception was not thrown\n";
    } catch (const std::exception& e) {
        // std::cout << "Caught expected exception: " << e.what() << "\n";
    }
}

// Test memory alignment
void testMemoryAlignment() {
    // std::cout << "\n===== Testing Memory Alignment =====\n";
    
    // Test alignas
    struct alignas(64) AlignedStruct {
        char data[64];
    };
    
    AlignedStruct s;
     std::cout << "AlignedStruct alignment: "
              << (reinterpret_cast<uintptr_t>(&s) % 64 == 0 ? "correct" : "incorrect") << "\n";
    
    // Simpler approach using aligned objects directly
    alignas(16) int aligned_int = 42;
    std::cout << "Aligned int value: " << aligned_int << "\n";
    std::cout << "Aligned int alignment: "
              << (reinterpret_cast<uintptr_t>(&aligned_int) % 16 == 0 ? "correct" : "incorrect") << "\n";
    
    // Test with std::vector which handles alignment internally
    std::vector<double> aligned_vector(5, 3.14);
    std::cout << "Vector alignment: "
              << (reinterpret_cast<uintptr_t>(aligned_vector.data()) % alignof(double) == 0 ? "correct" : "incorrect") << "\n";
}

// Test SFINAE
template<typename T>
auto testHasSize(int) -> decltype(std::declval<T>().size(), std::true_type{});

template<typename T>
auto testHasSize(...) -> std::false_type;

// Test variadic templates
template<typename... Args>
auto sum(Args... args) {
    return (args + ...);
}

void testTemplateMetaprogramming() {
    // std::cout << "\n===== Testing Template Metaprogramming =====\n";
    
    std::cout << "Vector has size(): " 
              << std::boolalpha << decltype(testHasSize<std::vector<int>>(0))::value << "\n";
    std::cout << "Int has size(): " 
              << std::boolalpha << decltype(testHasSize<int>(0))::value << "\n";
    
    // std::cout << "Sum of 1,2,3,4,5: " << sum(1,2,3,4,5) << "\n";
}
void testConcurrency() {
    // std::cout << "\n===== Testing Concurrency =====\n";
    
    std::atomic<int> counter(0);
    std::vector<std::thread> threads;
    
    for (int i = 0; i < 10; ++i) {
        threads.emplace_back([&counter]() {
            for (int j = 0; j < 1000; ++j) {
                counter++;
            }
        });
    }
    
    for (auto& t : threads) {
        t.join();
    }
    
    // std::cout << "Final counter value: " << counter << " (expected: 10000)\n";
}
void testOptimization() {
    // std::cout << "\n===== Testing Compiler Optimizations =====\n";
    
    // Test constant folding
    constexpr int result = 1 + 2 + 3 + 4 + 5;
    static_assert(result == 15, "Constant folding failed");
    
    // Test loop unrolling (indirect test)
    auto start = std::chrono::high_resolution_clock::now();
    volatile int sum = 0;
    for (int i = 0; i < 10000000; ++i) {
        sum += i & 1;
    }
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> elapsed = end - start;
    
    std::cout << "Loop execution time: " << elapsed.count() << "ms\n";
}
int test_a() {
    // std::cout << "Testing the Rule of Three/Five/Zero\n";
    testRuleOfThree();
    testRuleOfFive();
    testRuleOfZero();
    testExceptionSafety();
    testMemoryAlignment();
    testTemplateMetaprogramming();
    testConcurrency();
    testOptimization();
    // std::cout << "\nAll tests completed.\n";
    return 0;
}
#endif // INTEGRITY_H
/*  
Potential Future Enhancements

Filesystem Operations: Test C++17 <filesystem> features
Regular Expressions: Test <regex> functionality
Random Number Generation: Test the quality of random number generators
Floating-Point Compliance: Test IEEE 754 compliance
Unicode Support: Test handling of Unicode strings and conversions
*/