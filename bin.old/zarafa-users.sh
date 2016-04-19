#!/bin/bash
#
#     Script to list Zarafa users
#     Bob Brandt <projects@brandt.ie>
#

ZARAFAADMINCMD='/usr/sbin/zarafa-admin'
VERSION=0.3
OUTPUT='text'
HEADER='yes'
FILTER=''

base64convert() {
	while read line
	do
		if echo "$line" | grep "::\s" > /dev/null ; then
			field=$( echo "$line" | sed 's|::\s.*||' )
			value=$( echo "$line" | sed 's|.*:\s\+||' | base64 -dw0 )
			echo "$field: $value"
		else
			echo "$line"
		fi
	done
}

trim() { echo -e "$*" | sed -e "s|^\s*||" -e "s|\s*$||" ; }

safe4xml() {
	while read line
	do
		output=$( echo -e "$line" | sed "s|&|\&amp;|g")
		output=$( echo -e "$output" | sed "s|<|\&lt;|g")
		output=$( echo -e "$output" | sed "s|>|\&gt;|g")
		output=$( echo -e "$output" | sed "s|\"|\&quot;|g")
		output=$( echo -e "$output" | sed "s|'|\&apos;|g")						
		echo -e "$output"
	done
}

safe4csv() {
	while read line
	do
		output=$( echo -e "$line" | sed "s|,|;|g")				
		echo -e "$output"
	done
}




usage() {
        [ "$2" == "" ] || echo -e "$2"
        echo -e "Usage: $0 [options] filter"
        echo -e "Options:"
        echo -e " -o, --output    how to format output (text,xml,csv) text is default"
        echo -e " -n, --noheader  do not display a header row"
        echo -e " -h, --help      display this help and exit"
        echo -e " -v, --version   output version information and exit"
        exit ${1-0}
}

version() {
        echo -e "$0 $VERSION"
        echo -e "Copyright (C) 2011 Free Software Foundation, Inc."
        echo -e "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
        echo -e "This is free software: you are free to change and redistribute it."
        echo -e "There is NO WARRANTY, to the extent permitted by law.\n"
        echo -e "Written by Bob Brandt <projects@brandt.ie>."
        exit 0
}

# Execute getopt
ARGS=$(getopt -o o:nvh -l "output:,noheader,help,version" -n "$0" -- "$@") || usage 1 " "

#Bad arguments
#[ $? -ne 0 ] && usage 1 "$0: No arguments supplied!\n"

eval set -- "$ARGS";

while /bin/true ; do
    case "$1" in
        -o | --output )    OUTPUT=$( echo "$2" | tr '[:upper:]' '[:lower:]' ) ; shift ;;
        -n | --noheader )  HEADER= ;;
        -h | --help )      usage 0 ;;
        -v | --version )   version ;;
        -- )               shift ; break ;;
        * )                usage 1 "$0: Invalid argument!\n" ;;
    esac
    shift
done
FILTER="$1"

echo "$OUTPUT" | grep -i "^\(text\|csv\|xml\)$" > /dev/null || usage 1 "$0: Incorrect Output Type\n"

RESULTS=$( $ZARAFAADMINCMD -l | tail -n +5 | sed -e 's|^\s*||' -e 's|\s*$||' | tr -s "\t" | sed 's|\t|,|' )

if [ -z "$FILTER" ]; then
	RESULTS=$( echo -e "$RESULTS" | sort )
else
	RESULTS=$( echo -e "$RESULTS" | grep -i "$FILTER" | sort )
fi

case "$OUTPUT" in
	"csv" )	[ "$HEADER" == "yes" ] && echo -e "Username,Fullname,Homeserver"
			 	echo -e "$RESULTS" ;;
	"xml" )	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<results>"
				echo -e "$RESULTS" | safe4xml | sed -e 's|^|<result username="|' -e 's|,|" fullname="|' -e 's|,|homeserver="|' -e 's|$|"/>|'
				echo -e "</results>" ;;
	* )    	[ "$HEADER" == "yes" ] && RESULTS="Username,Fullname,Homeserver\n--------,--------,----------\n$RESULTS"
			 	echo -e "$RESULTS" | column -s "," -c 2 -t ;;
esac






























