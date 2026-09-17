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
    : # all checks passed — actual assembly logic goes here next
fi
