#!/bin/bash

# Prompt the user for the filename
echo "Enter the filename to search for:"
read filename

# Optional: Prompt the user for the directory to search in
echo "Enter the directory to search in (default is current directory):"
read directory

# Use current directory if no directory is provided
directory=${directory:-.}

echo "Searching for '$filename' in '$directory'..."
result=$(find "$directory" -name "$filename")

if [ -n "$result" ]; then
    echo "Found file(s): $result"
else
    echo "No files found matching '$filename'."
fi

