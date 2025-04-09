#!/bin/bash

# Hash Comparator Script
# This script analyzes what changed and what stayed the same between origin.hash and new.hash

# Define the hash files
ORIGINAL_HASH="origin.hash"
NEW_HASH="new.hash"

echo "Comparing hash files: $ORIGINAL_HASH and $NEW_HASH"
echo "========================================================"

# Create temporary files with sorted content for better comparison
original_sorted=$(mktemp)
new_sorted=$(mktemp)

# Process files while skipping the first line (header)
sed '1d' "$ORIGINAL_HASH" > "$original_sorted"
sed '1d' "$NEW_HASH" > "$new_sorted"

echo -e "\n[UNCHANGED FILES]"
echo "-----------------"
# Find files with unchanged hashes and sizes
while IFS=, read -r hash file size; do
    # Clean up potential spaces and convert to proper format
    hash=$(echo "$hash" | tr -d ' ')
    file=$(echo "$file" | tr -d ' ')
    size=$(echo "$size" | tr -d ' ')
    
    # Search for exact match
    if grep -q "^$hash,$file,$size" "$new_sorted"; then
        echo "✓ $file (Hash: ${hash:0:8}..., Size: $size bytes)"
    fi
done < "$original_sorted"

echo -e "\n[MODIFIED FILES]"
echo "----------------"
# Find files that exist in both but have different hashes or sizes
while IFS=, read -r old_hash file old_size; do
    # Clean up potential spaces
    old_hash=$(echo "$old_hash" | tr -d ' ')
    file=$(echo "$file" | tr -d ' ')
    old_size=$(echo "$old_size" | tr -d ' ')
    
    # Use grep with file name surrounded by commas to ensure exact match
    new_line=$(grep ",$file," "$new_sorted")
    if [ -n "$new_line" ]; then
        new_hash=$(echo "$new_line" | cut -d, -f1 | tr -d ' ')
        new_size=$(echo "$new_line" | cut -d, -f3 | tr -d ' ')
        
        if [ "$old_hash" != "$new_hash" ] || [ "$old_size" != "$new_size" ]; then
            # Convert to integers before arithmetic
            old_size_num=$(echo "$old_size" | sed 's/[^0-9]*//g')
            new_size_num=$(echo "$new_size" | sed 's/[^0-9]*//g')
            
            # Only do arithmetic if both are valid numbers
            if [[ "$old_size_num" =~ ^[0-9]+$ ]] && [[ "$new_size_num" =~ ^[0-9]+$ ]]; then
                size_diff=$((new_size_num - old_size_num))
                if [ $size_diff -ge 0 ]; then
                    size_diff="+$size_diff"
                fi
                echo "⟳ $file (Old Hash: ${old_hash:0:8}..., New Hash: ${new_hash:0:8}...)"
                echo "   Size changed: $old_size → $new_size bytes ($size_diff bytes)"
            else
                echo "⟳ $file (Old Hash: ${old_hash:0:8}..., New Hash: ${new_hash:0:8}...)"
                echo "   Size changed: $old_size → $new_size bytes"
            fi
        fi
    fi
done < "$original_sorted"

echo -e "\n[NEW FILES]"
echo "----------"
# Find files that are in the new hash but not in the original
while IFS=, read -r hash file size; do
    # Clean up potential spaces
    hash=$(echo "$hash" | tr -d ' ')
    file=$(echo "$file" | tr -d ' ')
    size=$(echo "$size" | tr -d ' ')
    
    # Look for file name in original hash
    if ! grep -q ",$file," "$original_sorted"; then
        echo "+ $file (Hash: ${hash:0:8}..., Size: $size bytes)"
    fi
done < "$new_sorted"

echo -e "\n[DELETED FILES]"
echo "--------------"
# Find files that are in the original hash but not in the new
while IFS=, read -r hash file size; do
    # Clean up potential spaces
    hash=$(echo "$hash" | tr -d ' ')
    file=$(echo "$file" | tr -d ' ')
    size=$(echo "$size" | tr -d ' ')
    
    # Look for file name in new hash
    if ! grep -q ",$file," "$new_sorted"; then
        echo "- $file (Hash: ${hash:0:8}..., Size: $size bytes)"
    fi
done < "$original_sorted"

# Clean up temporary files
rm "$original_sorted" "$new_sorted"

echo -e "\n========================================================"
echo "Analysis complete"