#!/bin/sh

function contains {
    for item in $2
    do
        if [ "$item" == "$1" ]; then
            echo true
            return
        fi
    done
    echo false
}

