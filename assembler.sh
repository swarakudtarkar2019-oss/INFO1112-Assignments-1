#!/bin/bash

if [ $# -eq 0 ]; then
    echo -e "usage: no argument is provided"
    exit 1
elif [ $# -gt 1 ]; then
    echo "usage: more than one arguments are provided"
    exit 1
elif ! [ -f "$1" ]; then 
    echo "usage: input is not a file or it does not exist"
    exit 1
elif [[ "$1" != *.vsc ]]; then
    echo "usage: input does not have the extension .vsc"
    exit 1
elif ! [ -s "$1" ]; then
    echo "usage: the file is empty – no .bin file is produced"
    exit 1
else
    n_values=$(sed -n '1p' "$1")
    total_lines=$(wc -l < "$1")
    
    declare -a bytes
    line_num=1
    
    # Read static values (lines 2 to n_values+1)
    for ((i=1; i<=n_values; i++)); do
        line_num=$((line_num+1))
        val=$(sed -n "${line_num}p" "$1")
        bytes+=($(printf "%02x" "$val"))
    done
    
    is_quit_only=true
    has_addsub=false
    
    # Read instructions (remaining lines)
    while ((line_num < total_lines)); do
        line_num=$((line_num+1))
        instr_line=$(sed -n "${line_num}p" "$1")
        [ -z "$instr_line" ] && continue
        
        IFS=',' read -r name reg addr <<< "$instr_line"
        
        case "$name" in
            LOAD) opcode=1 ;;
            STORE) opcode=2 ;;
            ADD) opcode=3; is_quit_only=false; has_addsub=true ;;
            SUB) opcode=4; is_quit_only=false; has_addsub=true ;;
            QUIT) opcode=8 ;;
            PRINT) opcode=9; is_quit_only=false ;;
        esac
        
        [ "$name" != "QUIT" ] && is_quit_only=false
        
        combined=$(( (opcode << 10) | (reg << 8) | addr ))
        byte1=$(( (combined >> 8) & 0xFF ))
        byte2=$(( combined & 0xFF ))
        
        bytes+=($(printf "%02x" "$byte1"))
        bytes+=($(printf "%02x" "$byte2"))
    done
    
    bin_file="${1%.vsc}.bin"
    printf '%s' "${bytes[@]}" | xxd -r -p > "$bin_file"
    
    if $is_quit_only; then
        echo "It is a QUIT program"
    elif $has_addsub; then
        echo "It is an ADD/SUB program"
    fi
    
    echo "The content of the .bin file is"
    for b in "${bytes[@]}"; do
        echo "$b"
    done
fi
