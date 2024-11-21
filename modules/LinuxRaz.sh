#!/bin/bash

# Hiển thị hộp thoại chọn tùy chọn
choice=$(zenity --list --title="Chọn một tùy chọn" --radiolist --column="Chọn" --column="Tùy chọn" TRUE "Nén tệp hoặc thư mục" FALSE "Giải nén tệp" --width=300 --height=200)

if [ "$choice" == "Nén tệp hoặc thư mục" ]; then
    # Nén tệp hoặc thư mục
    input=$(zenity --file-selection --title="Chọn tệp hoặc thư mục cần nén" --directory)
    if [ -z "$input" ]; then
        zenity --error --text="Bạn chưa chọn tệp hoặc thư mục nào."
        exit 1
    fi
    output=$(zenity --entry --title="Tên file nén đầu ra" --text="Nhập tên file nén đầu ra (không cần phần mở rộng):")
    if [ -z "$output" ]; then
        zenity --error --text="Bạn chưa nhập tên file nén đầu ra."
        exit 1
    fi

    # Tạo file nén
    tar -czvf "$output".tar.gz "$input" > /dev/null 2>&1
    zenity --info --text="Đã nén $input thành file $output.tar.gz"

elif [ "$choice" == "Giải nén tệp" ]; then
    # Giải nén tệp
    input=$(zenity --file-selection --title="Chọn tệp nén (.tar.gz hoặc .rar) cần giải nén")
    if [ -z "$input" ]; then
        zenity --error --text="Bạn chưa chọn tệp nào để giải nén."
        exit 1
    fi

    if [[ "$input" == *.tar.gz ]]; then
        tar -xzvf "$input" > /dev/null 2>&1
        zenity --info --text="Đã giải nén $input"
    elif [[ "$input" == *.rar ]]; then
        if command -v unrar &> /dev/null; then
            unrar x "$input" > /dev/null 2>&1
            zenity --info --text="Đã giải nén $input"
        else
            zenity --error --text="unrar chưa được cài đặt. Vui lòng cài đặt unrar và thử lại."
            exit 1
        fi
    else
        zenity --error --text="Định dạng tệp không được hỗ trợ."
        exit 1
    fi

else
    zenity --error --text="Lựa chọn không hợp lệ. Vui lòng chọn 'Nén tệp hoặc thư mục' hoặc 'Giải nén tệp'."
    exit 1
fi

