#ifndef DATAFILE_INTEGRITY_H
#define DATAFILE_INTEGRITY_H

#include <iostream>
#include <filesystem>
#include <string>
#include <vector>
#include <array>
#include <fstream>
#include <sstream>
#include <iomanip>  // For setw, setfill

namespace fs = std::filesystem;

// Structure to hold file information
struct FileInfo
{
    std::string name;
    size_t size;
    uint_fast64_t hash;
};

// Function to check if a directory exists
bool directoryExists(const std::string &path)
{
    if (path.empty())
    {
        return false;
    }
    try
    {
        return fs::exists(path) && fs::is_directory(path);
    }
    catch (const std::exception &)
    {
        return false;
    }
}

// Function to calculate a file hash using the FNV-1a algorithm
uint_fast64_t calculateFileHash(const std::string &filePath)
{
    std::ifstream file(filePath, std::ios::binary);
    if (!file)
    {
        std::cerr << "Error opening file for hashing: " << filePath << std::endl;
        return 0;
    }
    // FNV-1a hash parameters
    const uint_fast64_t FNV_PRIME = 1099511628211ULL;
    const uint_fast64_t FNV_OFFSET_BASIS = 14695981039346656037ULL;
    // Initialize hash value
    uint_fast64_t hash = FNV_OFFSET_BASIS;
    // Use a buffer for efficient reading
    char buffer[16384]; // 16KB buffer
    // Process the file in chunks
    while (file)
    {
        file.read(buffer, sizeof(buffer));
        std::streamsize bytesRead = file.gcount();
        if (bytesRead == 0)
            break;
        // Process each byte in the buffer
        for (std::streamsize i = 0; i < bytesRead; ++i)
        {
            // FNV-1a hash algorithm
            hash ^= static_cast<unsigned char>(buffer[i]);
            hash *= FNV_PRIME;
        }
    }
    // Get file size
    uint_fast64_t fileSize = 0;
    try
    {
        fileSize = fs::file_size(filePath);
        // Mix in the file size
        hash ^= fileSize;
        hash *= FNV_PRIME;
    }
    catch (...)
    {
        // Ignore file size errors
    }
    return hash;
}

// Function to list files in a directory and calculate hashes
std::vector<FileInfo> listFilesWithHash(const std::string &path)
{
    std::vector<FileInfo> fileInfoList;
    if (path.empty())
    {
        return fileInfoList;
    }
    try
    {
        // Check if directory exists
        if (!directoryExists(path))
        {
            std::cout << "Directory does not exist: " << path << std::endl;
            return fileInfoList;
        }
        // Iterate through directory (non-recursive)
        for (const auto &entry : fs::directory_iterator(path))
        {
            if (fs::is_regular_file(entry))
            {
                FileInfo info;
                info.name = entry.path().filename().string();
                info.size = fs::file_size(entry.path());
                info.hash = calculateFileHash(entry.path().string());
                fileInfoList.push_back(info);
            }
        }
    }
    catch (const std::exception &e)
    {
        std::cerr << "Error processing directory: " << path << " - " << e.what() << std::endl;
    }
    return fileInfoList;
}

// Function to save file information to a text file with fixed-width hash values
bool saveFileInfoToTxt(const std::vector<FileInfo> &fileInfoList, const std::string &outputPath)
{
    std::ofstream outFile(outputPath);
    if (!outFile)
    {
        std::cerr << "Error creating output file: " << outputPath << std::endl;
        return false;
    }
    
    // Define the width for hash values (max digits in uint_fast64_t)
    const int HASH_WIDTH = 20;  // 2^64-1 has 20 digits
    
    outFile << "Hash Value,File Name,Size (bytes)\n";
    
    for (const auto &info : fileInfoList)
    {
        // Format hash with fixed width, zero-padded
        outFile << std::setw(HASH_WIDTH) << std::setfill('0') << info.hash 
                << "," << info.name 
                << "," << info.size << "\n";
    }
    
    outFile.close();
    return true;
}

// Function to scan specific directories, hash files, and save results
int test_b()
{
    // Define specific directories to scan
    const std::array<std::string, 3> specificDirectories = {
        "tools",
        "src",
        "include"
    };
    
    std::cout << "Scanning specific directories for files...\n" << std::endl;
    
    bool foundAnyDirectory = false;
    std::vector<FileInfo> allFileInfo;
    
    // Define the width for hash values (max digits in uint_fast64_t)
    const int HASH_WIDTH = 20;  // 2^64-1 has 20 digits
    
    // Iterate through each specific directory
    for (const auto &dirPath : specificDirectories)
    {
        // Skip empty paths
        if (dirPath.empty())
        {
            continue;
        }
        
        std::cout << "\n=== Scanning directory: " << dirPath << " ===" << std::endl;
        
        // Check if directory exists before attempting to list files
        if (directoryExists(dirPath))
        {
            foundAnyDirectory = true;
            
            // List files in the specified directory and calculate hashes
            std::vector<FileInfo> files = listFilesWithHash(dirPath);
            
            if (files.empty())
            {
                std::cout << "No files found in directory: " << dirPath << std::endl;
            }
            else
            {
                std::cout << "Files in directory " << dirPath << ":" << std::endl;
                for (const auto &file : files)
                {
                    // Format hash with fixed width, zero-padded for console output
                    std::cout << " Hash: " << std::setw(HASH_WIDTH) << std::setfill('0') << file.hash 
                              << " " << file.name 
                              << " (Size: " << file.size << " bytes)" << std::endl;
                    
                    // Add to the combined list
                    allFileInfo.push_back(file);
                }
                std::cout << "Total files: " << files.size() << std::endl;
            }
        }
        else
        {
            std::cout << "Directory does not exist: " << dirPath << std::endl;
        }
        
        std::cout << "\n--------------------------------------------------\n" << std::endl;
    }
    
    if (!foundAnyDirectory)
    {
        std::cout << "None of the specified directories were found." << std::endl;
        return 1;
    }
    
    // Save all file information to a text file
    std::string outputFileName = "new.hash";
    if (saveFileInfoToTxt(allFileInfo, outputFileName))
    {
        std::cout << "File information and hashes saved to: " << outputFileName << std::endl;
    }
    else
    {
        std::cerr << "Failed to save file information to: " << outputFileName << std::endl;
    }
    
    return 0;
}

#endif // DATAFILE_INTEGRITY_H