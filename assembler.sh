#!/bin/bash

if [ $# -eq 0 ]; then
    echo -e "usage: no argument is provided"
    exit 1
elif [ $# -gt 1 ]; then
    echo "usage: more than one arguments are provided"
    exit 1
else
    : #exactly one argument — this is where the next checks will go
fi
