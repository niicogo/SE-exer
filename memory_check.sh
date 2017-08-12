#!/bin/bash

TOTAL_MEMORY=$(free -m | grep Mem: | awk '{ print $2 }')
USED_MEMORY=$(free -m | grep Mem: | awk '{ print $3 }')
MEMORY_USAGE=$(printf "%s" $(($USED_MEMORY*100/$TOTAL_MEMORY)))

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

function HELP {
	echo -e \\n"${BOLD}Help documentation for $0${NORMAL}"\\n
	echo -e "${BOLD}script requires 3 parameters.${NORMAL}"\\n
        echo "Sample invocation: $0 -c 90 -w 60 -e email@domain.com"
        echo "Sample invocation: $0 -e email@domain.com -w 60 -c 90"
        echo -e \\n"${BOLD}-c${NORMAL}		critical threshold (percentage)"
        echo "${BOLD}-w${NORMAL}		warning threshold (percentage)"
        echo "${BOLD}-e${NORMAL}		email address to send the report"
	exit
}

NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
	HELP
fi

while getopts "c:w:e:" FLAG; do
case $FLAG in
	c)	
		OPT_C=$OPTARG
		;;
	w)	
		OPT_W=$OPTARG
		;;
	e)	
		OPT_E=$OPTARG
		;;
	\?)
#		echo -e \\n"${BOLD}-$OPTARG${NORMAL} is not allowed."
		HELP	
		;;
esac
done

shift $((OPTIND-1)) #move to next argument

echo "Mem usage: $MEMORY_USAGE"

if [ $OPT_W -gt $OPT_C ]; then
	echo -e \\n"${BOLD}-w${NORMAL} should be less than ${BOLD}-c${NORMAL}"
	HELP
fi

#memory usage is greater than or equal to critical threshold
if [ $MEMORY_USAGE -ge $OPT_C ]; then
	SUBJECT="$(date "+%Y%m%d %H:%M") memory check - critical"
	MESSAGE=$(ps aux --sort -rss | head -n 10)
	echo -e "$MESSAGE" | mail -s "$SUBJECT" "$OPT_E"
	exit 2
fi

#memory usage is greater than or equal to warning threshold but less than critical threshold
if [ $MEMORY_USAGE -ge $OPT_W ] && [ $MEMORY_USAGE -lt $OPT_C  ]; then
	exit 1
fi

#memory usage is less than warning threshold
if [ $MEMORY_USAGE -lt $OPT_W ]; then
	exit 0
fi

