#!/bin/bash

# Function to print file type
printFileType() {
    echo "--- File Information ---"
    if [ -f "$1" ]; then
        echo "File Type: Regular file"
    elif [ -d "$1" ]; then
        echo "File Type: Directory"
    elif [ -c "$1" ]; then
        echo "File Type: Character device"
    elif [ -b "$1" ]; then
        echo "File Type: Block device"
    elif [ -p "$1" ]; then
        echo "File Type: FIFO/pipe"
    elif [ -h "$1" ]; then
        echo "File Type: Symbolic link"
    elif [ -S "$1" ]; then
        echo "File Type: Socket"
    else
        echo "File Type: Unknown"
    fi
}

# Function to display file permissions
translatePermissions() {
    perms=$(stat -c "%A" "$1")
    echo "Permissions: $perms"
}

# Function to process a file or directory
processFileOrDirectory() {
    echo "--- Processing File/Folder ---"
    echo "Selected file/folder: $1"
    printFileType "$1"
    linkCount=$(stat -c "%h" "$1")
    echo "Number of links: $linkCount"
    translatePermissions "$1"
    accessTime=$(stat -c "%x" "$1")
    echo "Last access time: $accessTime"
    echo "-----------------------------"
}

# Main logic
echo "Choose an option:"
echo "1. Select a File"
echo "2. Select a Directory"
echo "3. Select a Text File with Multiple Paths"
read -p "Enter your choice (1, 2, or 3): " choice

if [ "$choice" == "1" ]; then
    filePath=$(zenity --file-selection --title="Select a File")
elif [ "$choice" == "2" ]; then
    filePath=$(zenity --file-selection --title="Select a Directory" --directory)
elif [ "$choice" == "3" ]; then
    filePath=$(zenity --file-selection --title="Select a Text File with Paths" --file-filter='*.txt')
else
    zenity --error --text="Invalid choice. Exiting."
    exit 1
fi

# Create a temporary file to store the results
tempResultFile=$(mktemp)

if [ "$choice" == "3" ]; then
    # Open the text file and process each path
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            processFileOrDirectory "$line" >> "$tempResultFile"
        fi
    done < "$filePath"
else
    processFileOrDirectory "$filePath" >> "$tempResultFile"
fi

# Display the results in a new Zenity window
zenity --text-info --title="File/Directory Information" --filename="$tempResultFile"

# Clean up the temporary file
rm "$tempResultFile"

exit 0

