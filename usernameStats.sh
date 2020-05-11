#! /bin/bash

usage() {
    echo "Usage: $0 [-n <num>] [-f <filename>]";
    exit 1;
}
num=""
file="/var/log/btmp"
while getopts ":n:f:" option ; do
    case "${option}" in
        n)
            if [ $OPTARG -eq $OPTARG ] 2>/dev/null; then
                num=${OPTARG}
            else
                echo "$0: Invalid number: $OPTARG"
                usage
            fi
            ;;
        f)
            if [ -f $OPTARG ]; then
                file=${OPTARG}
            else
                echo "$0: Cannot open $OPTARG: No such file"
                usage
            fi
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$num" ]; then
    trailer=""
else
    trailer="| head -n $num"
fi
# the "head -n -2" is to remove the last two lines of output, because lastb finishes
# with an empty line and a line describing when the log begins
baseOptions="| head -n -2 | awk '{ print \$1 }' | sort | uniq -c | sort -gr"
eval "lastb -f $file $baseOptions $trailer"
