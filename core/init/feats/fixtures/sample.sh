#!/bin/bash

NAME="world"
COUNT=5

if [ "$NAME" = "world" ]; then
    echo "Hello, $NAME!"
fi

if [ $COUNT -gt 3 ]; then
    echo "Count is greater than 3"
fi

for i in 1 2 3; do
    echo "Loop iteration: $i"
done

while [ $COUNT -gt 0 ]; do
    echo "Countdown: $COUNT"
    COUNT=$((COUNT - 1))
done

case $NAME in
    world) echo "It's a small world" ;;
    *) echo "Unknown name" ;;
esac
