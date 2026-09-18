#!/bin/bash

if [ $# -eq 0 ]; then
    echo "usage: no argument is provided"
    exit 1
elif [ $# -gt 1 ]; then
    echo "usage: more than one arguments are provided"
    exit 1
elif ! [ -f "$1" ]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
elif [[ "$1" != *.bin ]]; then
    echo "usage: input does not have the extension .bin"
    exit 1
elif ! [ -s "$1" ]; then
    echo "usage: the file is empty"
    exit 1
fi

# Set up memory (256 bytes) and registers (4), all zeroed
declare -a memory
declare -a registers
for ((i=0; i<256; i++)); do memory[$i]=0; done
for ((i=0; i<4; i++)); do registers[$i]=0; done

# Read the .bin file's bytes into an array, as decimal values
byte_list=()
while IFS= read -r byte; do
    byte_list+=("$byte")
done < <(xxd -p -c1 "$1")
num_bytes=${#byte_list[@]}
N=-1
for ((candidate=0; candidate<num_bytes; candidate++)); do
    valid=1
    last_opcode=-1
    for ((p=candidate; p<num_bytes-1; p+=2)); do
        b1=$((16#${byte_list[$p]}))
        b2=$((16#${byte_list[$((p+1))]}))
        opcode=$((b1 >> 2))
        case $opcode in
            1|2|3|4|8|9) last_opcode=$opcode ;;
            *) valid=0; break ;;
        esac
    done
    if [ "$valid" -eq 1 ] && [ "$last_opcode" -eq 8 ]; then
        N=$candidate
        break
    fi
done

if [ "$N" -lt 0 ]; then
    echo "usage: no valid program instructions found"
    exit 1
fi
for ((i=0; i<N; i++)); do
    memory[$i]=$(( 16#${byte_list[$i]} ))
done
pc=$N
while ((pc < num_bytes)); do
    byte1_hex=${byte_list[$pc]}
    byte2_hex=${byte_list[$((pc+1))]}
    byte1=$((16#$byte1_hex))
    byte2=$((16#$byte2_hex))

    opcode=$((byte1 >> 2))
    reg=$((byte1 & 3))
    addr=$byte2

    case $opcode in
        1) # LOAD
            registers[$reg]=${memory[$addr]}
            ;;
        2) # STORE
            memory[$addr]=${registers[$reg]}
            ;;
        3) # ADD
            registers[$reg]=$(( registers[$reg] + memory[$addr] ))
            ;;
        4) # SUB
            if (( registers[$reg] >= memory[$addr] )); then
                registers[$reg]=$(( registers[$reg] - memory[$addr] ))
            else
                echo "Error: cannot SUB, register value is less than memory value"
            fi
            ;;
        8) # QUIT
            break
            ;;
        9) # PRINT
            echo "${registers[$reg]}"
            ;;
    esac

    pc=$((pc+2))
done
