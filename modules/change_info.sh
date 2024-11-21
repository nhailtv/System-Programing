#!/bin/bash

# Function to rename file
changeFileName() {
    if mv "$1" "$2"; then
        echo "File renamed successfully!"
    else
        echo "Error renaming file"
    fi
}

# Function to change last access time
changeLastAccessTime() {
    if touch -a -t "$(date -d @$1 +'%Y%m%d%H%M.%S')" "$2"; then
        echo "Last access time changed successfully!"
    else
        echo "Error changing last access time"
    fi
}

# Function to change file permissions
changeFilePermissions() {
    if chmod "$1" "$2"; then
        echo "File permissions changed successfully!"
    else
        echo "Error changing file permissions"
    fi
}

# Function to change file owner
changeFileOwner() {
    if chown "$1":"$2" "$3"; then
        echo "File owner changed successfully!"
    else
        echo "Error changing file owner"
    fi
}

# Prompt user to choose a file with a graphical dialog
fileName=$(zenity --file-selection --title="Select a file")

# Check if the user canceled the file selection
if [ -z "$fileName" ]; then
    echo "No file selected, exiting..."
    exit 1
fi

# Main script logic
choice=0
while [ "$choice" -ne 5 ]; do
    echo "===== MENU ====="
    echo "1. Rename file"
    echo "2. Change last access time"
    echo "3. Change file permissions"
    echo "4. Change file owner"
    echo "5. Exit"
    echo "Choose an option (1-5): "
    read choice

    case $choice in
        1)
            echo "Enter the new file name: "
            read newName
            changeFileName "$fileName" "$newName"
            fileName="$newName"  # Update fileName to the new name
            ;;
        2)
            echo "Enter new last access time (Unix timestamp): "
            read newTime
            changeLastAccessTime "$newTime" "$fileName"
            ;;
        3)
            echo "Enter new permissions (octal): "
            read newMode
            changeFilePermissions "$newMode" "$fileName"
            ;;
        4)
            echo "Enter new owner: "
            read ownerName
            echo "Enter new group: "
            read groupName
            changeFileOwner "$ownerName" "$groupName" "$fileName"
            ;;
        5)
            echo "Exiting the program..."
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac
done

