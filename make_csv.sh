#!/bin/bash

if [ -n "$1" -a -n "$2" ]; then
  cat $2 | awk '{print $1}' | \
    xargs /usr/bin/python /usr/bin/pmrep -a $1 -f "%H:%M:%S" -o csv -t 60s -S -3hour | \
    sed '1s/^Time/time/'
fi
