#! /bin/bash

usage() {
    echo "Usage: $0 [-n <num> [-t]] [-f <filename>] [-p]";
    echo "-n <num>         Print the top <num> usernames"
    echo "-t               Prints the percentage of attempts top <num> usernames are"
    echo "-f <filename>    Set file, default /var/log/btmp"
    echo "-p               Prints the percentage of failure next to number of attempts"
    exit 1;
}
num=""
file="/var/log/btmp"
totalPercentage=false
singlePercentage=false
while getopts ":n:f:tp" option ; do
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
        p)
            singlePercentage=true
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
baseOptions="| head -n -2 | awk '{ print \$1 }' | sort | uniq -c | sort -gr | awk '{ print \$1 \"\t\" \$2 } '"
output=$(eval "lastb -f $file $baseOptions $trailer")

# If -t is passed with -n, we compute the percentage the top n username are in failed attempts
if [ $totalPercentage = true ]; then
    attempts=$(lastb -f ${file} | head -n -2 | wc -l)
    sumOfTopN=$(echo "${output}" | awk '{ print $1 }' | paste -sd+ | bc )
    percentage=$(echo "$sumOfTopN/$attempts*100" | bc -l )
    percentageStat=$( printf "The top %d usernames represent %.4f%% of failed login attempts(%d)" ${num} ${percentage} ${attempts})
    echo $percentageStat
fi

# we calculate the single percentage for each user
if [ $singlePercentage = true ]; then
    attempts=$(lastb -f ${file} | head -n -2 | wc -l)
    output=$(echo "${output}" | awk " { per = \$1 / $attempts * 100; print \$1,  per \"%\" \"\t\" \$2} ")
fi
echo "${output}"
