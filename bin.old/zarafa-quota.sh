#!/bin/bash
#
#     Script to list all uses and their quota/disk usage
#     Bob Brandt <projects@brandt.ie>
#  

ZARAFAADMINCMD='/usr/sbin/zarafa-admin'
VERSION=0.2
OUTPUT='text'
HEADER='yes'

printuserquota() {
	[ "$HEADER" == "yes" ] && echo "username,Full Name,Warning Level,Soft Level,Hard Level,Current Size"
	while [ -n "$1" ]; do
		username=$( echo "$1" | tr "[:upper:]" "[:lower:]" )
      if ! fullname=$( echo "$ZARAFAADMINOUTPUT" | grep -i "^\s\+$1\s\+" )
		then
      	echo "The username $1 is not a zarafa user" >&2
         exit 1
	   fi

		echo -n "$username,"
		echo -n "$fullname" | sed -e 's|^\s*\S*\s*||' -e 's|\s*$||'
	   echo -ne ","

		ZARAFADETAILS=$( $ZARAFAADMINCMD --type user --details "$username" )
		WARNINGLEVEL=$( echo "$ZARAFADETAILS" | sed -n -e 's|\s*Warning level:\s*||p' -e 's|\s*$||' )
      SOFTLEVEL=$( echo "$ZARAFADETAILS" | sed -n -e 's|\s*Soft level:\s*||p' -e 's|\s*$||' )
      HARDLEVEL=$( echo "$ZARAFADETAILS" | sed -n -e 's|\s*Hard level:\s*||p' -e 's|\s*$||' )
      CURRENTSIZE=$( echo "$ZARAFADETAILS" | sed -n -e 's|\s*Current store size:\s*||p' -e 's|\s*$||' )

		echo -e "$WARNINGLEVEL,$SOFTLEVEL,$HARDLEVEL,$CURRENTSIZE"
		shift
	done
	return 0
}

usage() {
        [ "$2" == "" ] || echo -e "$2"
        echo -e "Usage: $0 [options] [username1,username2,...]"
        echo -e "Options:"
        echo -e " -o, --output    how to format output (text,csv,html) text is default"
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
             --noheader )  HEADER= ;;
        -h | --help )      usage 0 ;;
        -v | --version )   version ;;
        -- )               shift ; break ;;
        * )                usage 1 "$0: Invalid argument!\n" ;;
    esac
    shift
done

echo "$OUTPUT" | grep -i "^\(text\|html\|xml\|csv\)$" > /dev/null || usage 1 "$0: Incorrect Output Type\n"

ZARAFAADMINOUTPUT=$( $ZARAFAADMINCMD -l )

if [ -n "$1" ]; then
	usernamelist=$@
else
	declare -i count=$( echo "$ZARAFAADMINOUTPUT" | sed -n 's|User list for Default(\([0-9]*\).*|\1|p' )
	[ "$HEADER" == "yes" ] && [ "$OUTPUT" == "text" ] && echo "Quota Report for all $count Users"
	usernamelist=$( echo "$ZARAFAADMINOUTPUT" | sed '/^$/d' | tail -n $count | sed -e 's|^\s*||' -e 's|\s\+.*||' | grep -v "SYSTEM" | sort -f )
fi

case "$OUTPUT" in
   "csv" )  printuserquota $usernamelist ;;
   "html" ) echo -e '<table>'
				HEADER='yes'   
            printuserquota $usernamelist 2>&1 | sed -e 's|,|</td><td>|g' -e 's|^|<tr><td>|' -e 's|$|</td></tr>|' -e '1 s|td>|th>|g'
            echo -e '</table>' ;;
   "xml" )  echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<output>'
   			HEADER=
            printuserquota $usernamelist 2>&1 | sed -e 's|^|<user username="|g' -e 's|,|" fullname="|' -e 's|,|" warning="|' -e 's|,|" soft="|' -e 's|,|" hard="|' -e 's|,|" ="|' -e 's|$|"/>|'
            echo -e '</output>' ;;
   * )      printuserquota $usernamelist 2>&1 | sed -e 's|,| (|' -e 's|,|),|' | column -s "," -c 5 -t ;;
esac



