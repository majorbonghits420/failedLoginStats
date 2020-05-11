#! /bin/bash

# usage ./usernameStats.sh [-n #] <btmp file>
baseOptions=" | awk '{ print \$1 }' | sort | uniq -c | sort -gr"
trailer=""
if [ $# -eq 3 ]; then
    file=$3
    trailer="| head -n $2"
elif [ $# -eq 1 ]; then
    file=$1
fi
eval "lastb -f $file $baseOptions $trailer"
