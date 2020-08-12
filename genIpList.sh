#! /bin/sh

usage () {
    echo "Usage: $0 -b <btmp file>"
    echo "-b <filename>    Filename of btmp to pull IPs from"
    exit 1;
}
file=""
while getopts "b:" option ; do
    case "${option}" in
        b)
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
if [ "$file" == "" ]; then
    echo "$0: Requires a btmp file to parse"
    usage
fi
lastb -a -f "$file" | head -n -2 | awk '{print $NF}'
