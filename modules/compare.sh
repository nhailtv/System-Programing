#!/bin/bash

# Hiển thị hộp thoại chọn tùy chọn
choice=$(zenity --list --title="Chọn một tùy chọn" --radiolist --column="Chọn" --column="Tùy chọn" TRUE "So sánh hai tệp" FALSE "So sánh hai thư mục" --width=300 --height=200)

if [ "$choice" == "So sánh hai tệp" ]; then
    # So sánh hai tệp
    file1=$(zenity --file-selection --title="Chọn tệp thứ nhất")
    file2=$(zenity --file-selection --title="Chọn tệp thứ hai")

    if [ -f "$file1" ] && [ -f "$file2" ]; then
        diff_output=$(diff "$file1" "$file2")
        if [ "$diff_output" == "" ]; then
            zenity --info --text="Hai tệp giống nhau."
        else
            zenity --text-info --title="Sự khác biệt giữa hai tệp" --width=600 --height=400 --filename=<(echo "$diff_output")
        fi
    else
        zenity --error --text="Một trong hai tệp không tồn tại."
    fi

elif [ "$choice" == "So sánh hai thư mục" ]; then
    # So sánh hai thư mục
    dir1=$(zenity --file-selection --directory --title="Chọn thư mục thứ nhất")
    dir2=$(zenity --file-selection --directory --title="Chọn thư mục thứ hai")

    if [ -d "$dir1" ] && [ -d "$dir2" ]; then
        diff_output=$(diff -r "$dir1" "$dir2")
        if [ "$diff_output" == "" ]; then
            zenity --info --text="Hai thư mục giống nhau."
        else
            zenity --text-info --title="Sự khác biệt giữa hai thư mục" --width=600 --height=400 --filename=<(echo "$diff_output")
        fi
    else
        zenity --error --text="Một trong hai thư mục không tồn tại."
    fi

else
    zenity --error --text="Lựa chọn không hợp lệ. Vui lòng chọn 'So sánh hai tệp' hoặc 'So sánh hai thư mục'."
fi

