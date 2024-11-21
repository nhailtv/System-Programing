#!/bin/bash

# Choose a file using a GUI dialog
file=$(zenity --file-selection --file-filter="Text files (*.txt)" --title="Select a Text File")

# Check if a file was selected
if [ -z "$file" ]; then
echo "No file selected."
exit 1
fi

# Count the number of lines in the file
line_count=$(wc -l < "$file")

# Print the line count
echo "Number of lines: $line_count"