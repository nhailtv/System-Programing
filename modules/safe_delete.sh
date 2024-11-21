#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename=$1

# Kiểm tra xem file có tồn tại không
if [ ! -e "$filename" ]; then
    echo "File '$filename' does not exist."
    exit 1
fi


read -p "Are you sure you want to permanently delete '$filename'? (y/n) " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi


shred -u "$filename"
echo "File '$filename' has been securely deleted."
