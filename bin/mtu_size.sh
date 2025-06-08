#!/bin/bash

size=$2
myhost=$1

# Overhead is 28 - so lets subtact that before we start
size=$((size-28))

limit=0

while true; do

    echo "Sending $((size+28)) Bytes to $myhost"
    ping -M do -s $size -c "1" -W 1 $myhost > /dev/null 2>&1
    if [[ $? = 0 ]]; then
        break
        fi

        ((size--))
done

echo "Your Maximum MTU is $((size + 28))"
