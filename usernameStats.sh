#! /bin/bash

usage() {
    echo "Usage: $0 [-n <num> [-t]] [-f <filename>]";
    exit 1;
}
num=""
file="/var/log/btmp"
totalPercentage=false
while getopts ":n:f:t" option ; do
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
        t)
            totalPercentage=true
            ;;
        *)
            usage
            ;;
    esac
done

# -t should not appear without -n
if [ -z $num ] && [ $totalPercentage = true ]; then
    usage
fi

if [ -z "$num" ]; then
    trailer=""
else
    trailer="| head -n $num"
fi

# the "head -n -2" is to remove the last two lines of output, because lastb finishes
# with an empty line and a line describing when the log begins
baseOptions="| head -n -2 | awk '{ print \$1 }' | sort | uniq -c | sort -gr"
output=$(eval "lastb -f $file $baseOptions $trailer")

# If -t is passed with -n, we compute the percentage the top n username are in failed attempts
if [ $totalPercentage = true ]; then
    attempts=$(lastb -f ${file} | head -n -2 | wc -l)
    sumOfTopN=$(echo "${output}" | awk '{ print $1 }' | paste -sd+ | bc )
    percentage=$(echo "$sumOfTopN/$attempts*100" | bc -l )
    percentageStat=$( printf "The top %d usernames represent %.4f%% of failed login attempts(%d)" ${num} ${percentage} ${attempts})
    echo $percentageStat
fi

echo "${output}"
