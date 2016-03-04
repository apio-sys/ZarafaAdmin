#!/bin/bash
#
#     Script to list z-push users and their devices
#     Bob Brandt <projects@brandt.ie>
#

VERSION=0.2
OUTPUT='text'
HEADER='yes'
LIST=""
DEVICEID=""
DEVICETYPE=""
USERAGENT=""
DEVICEMODEL=""
DEVICEIMEI=""
DEVICENAME=""
DEVICEOS=""
DEVICEOSLANG=""
DEVICEOPER=""
VERSION=""
FIRSTSYNC=""
LASTSYNC=""
FOLDERTOTAL=""
FOLDERCOUNT=""
FOLDERS=""
STATUS=""
WIPEREQUESTON=""
WIPEREQUESTBY=""
WIPEDON=""
ERRORS=""


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

format-zpush() {
	LIST=
	FILTER=

	while read -t 1 data; do
		LIST="$LIST\n$data"
	done

	if [ -z "$LIST" ]; then
		LIST="$1"
		FILTER="$2"
	else
		FILTER="$1"
	fi

	LIST=$( echo -e "$LIST" | sed -s '/^$/d' )
	[ -n "$FILTER" ] && LIST=$( echo -e "$LIST" | grep -i "$FILTER" )
	IFS=$'\n'
	for line in $( echo -e "$LIST" ); do
		device=$( echo -e "$line" | sed 's|\s*\(\S*\).*|\1|')
		users=$( echo -e "$line" | sed -e 's|\s*\S*\s*\(\S*\).*|\1|' -e 's|,|\n|g' )
		#users=$( echo -e "$users" | sed 's|,|\n|g' )
		echo -e "$users" | sed "s|$|,$device|"
	done
}

outputdetails() {
	case "$OUTPUT" in
	    "csv" ) echo -ne "$USERNAME,$DEVICEID,$DEVICETYPE,$USERAGENT,$DEVICEMODEL,$DEVICEIMEI,$DEVICENAME,$DEVICEOS,$DEVICEOSLANG,$DEVICEOPER,$VERSION,$FIRSTSYNC,$LASTSYNC,$FOLDERTOTAL,$FOLDERCOUNT,$FOLDERS,$STATUS,$WIPEREQUESTON,$WIPEREQUESTBY,$WIPEDON,"
	    			echo -e "$ERRORS" | head -1 ;;
	    "xml" ) echo -ne "<result username=\"" ; echo -ne $( echo -e "$USERNAME" | safe4xml )"\""
	    			echo -ne " deviceid=\"" ; echo -ne $( echo -e "$DEVICEID" | safe4xml )"\""
	    			echo -ne " devicetype=\"" ; echo -ne $( echo -e "$DEVICETYPE" | safe4xml )"\""
	    			echo -ne " useragent=\"" ; echo -ne $( echo -e "$USERAGENT" | safe4xml )"\""
	    			echo -ne " devicemodel=\"" ; echo -ne $( echo -e "$DEVICEMODEL" | safe4xml )"\""
	    			echo -ne " deviceimei=\"" ; echo -ne $( echo -e "$DEVICEIMEI" | safe4xml )"\""
	    			echo -ne " devicename=\"" ; echo -ne $( echo -e "$DEVICENAME" | safe4xml )"\""
	    			echo -ne " deviceos=\"" ; echo -ne $( echo -e "$DEVICEOS" | safe4xml )"\""
	    			echo -ne " devicelanguage=\"" ; echo -ne $( echo -e "$DEVICEOSLANG" | safe4xml )"\""
	    			echo -ne " deviceoperator=\"" ; echo -ne $( echo -e "$DEVICEOPER" | safe4xml )"\""
	    			echo -ne " version=\"" ; echo -ne $( echo -e "$VERSION" | safe4xml )"\">"
	    			echo -ne "<folders firstsync=\"" ; echo -ne $( echo -e "$FIRSTSYNC" | safe4xml )"\""
	    			echo -ne " lastsync=\"" ; echo -ne $( echo -e "$LASTSYNC" | safe4xml )"\""
	    			echo -ne " total=\"" ; echo -ne $( echo -e "$FOLDERTOTAL" | safe4xml )"\""
	    			echo -ne " synced=\"" ; echo -ne $( echo -e "$FOLDERCOUNT" | safe4xml )"\""
	    			echo -ne " status=\"" ; echo -ne $( echo -e "$STATUS" | safe4xml )"\">"
	    			echo -ne $( echo -e "$FOLDERS" | safe4xml | sed -e 's|\s\+|"/><folder name="|g' -e 's|^|<folder name="|' -e 's|$|"/>|' )
	    			echo -ne "</folders>"
	    			echo -ne "<wipe requeston=\"" ; echo -ne $( echo -e "$WIPEREQUESTON" | safe4xml )"\""
	    			echo -ne " requestby=\"" ; echo -ne $( echo -e "$WIPEREQUESTBY" | safe4xml )"\""
	    			echo -ne " wipedon=\"" ; echo -ne $( echo -e "$WIPEDON" | safe4xml )"\"/>"
	            ERRORS=$( echo -e "$ERRORS" | safe4xml )
	            ERRORHEAD=$( echo -e "$ERRORS" | head -1 )
	    			echo -ne "<errors text=\"$ERRORHEAD\">"
            	echo -e "$ERRORS" | tail -n +2 | sed -e 's|^\s*Broken object:\s*\(.*\)|<error object="\1"|i' -e 's|^\s*Information:\s*\(.*\)| infomation="\1"|i' -e 's|^\s*Reason:\s*\(.*\)| reason="\1"|i' -e 's|^\s*Item/Parent id:\s*\(.*\)| id="\1"/>|i'            		            
	            echo -e "</errors></result>"
	            ;;
	    * )     tmp="Synchronized By User:,$USERNAME"
	    			tmp="$tmp\n""Device ID:,$DEVICEID"
	    			tmp="$tmp\n""Device Type:,$DEVICETYPE"
	    			tmp="$tmp\n""User Agent:,$USERAGENT"
	    			tmp="$tmp\n""Device Model:,$DEVICEMODEL"
	    			tmp="$tmp\n""Device IMEI:,$DEVICEIMEI"
	    			tmp="$tmp\n""Device Name:,$DEVICENAME"
	    			tmp="$tmp\n""Device OS:,$DEVICEOS"
	    			tmp="$tmp\n""Device Language:,$DEVICEOSLANG"
	    			tmp="$tmp\n""Device Operator:,$DEVICEOPER"
	    			tmp="$tmp\n""Version:,$VERSION"
	    			tmp="$tmp\n""First Sync:,$FIRSTSYNC"
	    			tmp="$tmp\n""Last Sync:,$LASTSYNC"
	    			tmp="$tmp\n""Total Folders:,$FOLDERTOTAL"
	    			tmp="$tmp\n""Synchronized Folders:,$FOLDERCOUNT"
	    			tmp="$tmp\n""Synchronized Data:,$FOLDERS"
	    			tmp="$tmp\n""Status:,$STATUS"
	    			tmp="$tmp\n""WipeRequest On:,$WIPEREQUESTON"
	    			tmp="$tmp\n""WipeRequest By:,$WIPEREQUESTBY"
	    			tmp="$tmp\n""Wiped on:,$WIPEDON"
	    			tmp="$tmp\n""Errors:,"$( echo -e "$ERRORS" | head -1 )
	    			tmp="$tmp\n"$( echo -e "$ERRORS" | tail -n +2 | sed -e 's|^\s*|  |' -e 's|:\s*|:,|' )
	    			echo ; echo -e "$tmp" | column -s "," -c 5 -t ;;
	esac
}

usage() {
        [ "$2" == "" ] || echo -e "$2"
        echo -e "Usage: $0 [options] objects"
        echo -e "Options:"
        echo -e " -o, --output    how to format output (text,csv,xml) text is default"
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

echo "$OUTPUT" | grep -i "^\(text\|xml\|csv\)$" > /dev/null || usage 1 "$0: Incorrect Output Type\n"

#LIST=$( z-push-admin -a list | sed -e '1,/^-\+$/d' -e '/^$/d' -e 's|\s*\(\S*\)\s*\(\S*\).*|\2,\1|' | sort )
FILTER="$1"
ALPHAFILTER=$( echo -e "$FILTER" | sed 's/[^a-zA-Z0-9]//g' )

LIST=$( z-push-admin -a list | sed -e '1,/^-\+$/d' -e '/^$/d' | format-zpush "$FILTER" | grep -i "$FILTER" | sort )

# Check if filter is full boundary word and not a sub-string or wildcard
[ -n "$ALPHAFILTER" ] && echo -e "$LIST" | grep "\b$ALPHAFILTER\b" > /dev/null
FULLMATCH=$?
if [ "$FULLMATCH" == "0" ]; then
	[ "$HEADER" == "yes" ] && [ "$OUTPUT" == "csv" ] && echo -e "Username,Device ID,Device Type,User Agent,Device Model,Device IMEI,Device Name,Device OS,Device Language,Device Operator,Version,First Sync,Last Sync,Total Folders,Synchronized Folders,Synchronized Data,Status,WipeRequest On,WipeRequest By,Wiped On,Errors"
	[ "$OUTPUT" == "xml" ] && echo -e "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<results format=\"details\">"

    tmp=$( echo -e "$LIST" | sed -e 's|^|-u |' -e 's|,|\n-d |' | sort -k2 -u | grep -i "$ALPHAFILTER" )



   	if [ -n "$tmp" ]; then
   		tmp=$( z-push-admin -a list $tmp | sed '/^$/d' )
   		IFS=$'\n'
		for LINE in $( echo -e "$tmp" ); do
			tmpusername1=$( echo -e "$LINE" | sed -n -e 's|\s*Synchronized devices of user:\s*||p' )
			tmpusername2=$( echo -e "$LINE" | sed -n -e 's|\s*Synchronized by user:\s*||p' )

			if [ -n "$tmpusername1" ] || [ -n "$tmpusername2" ] || echo -e "$LINE" | grep "^\-*$" > /dev/null 2>&1
			then
				[ -n "$USERNAME" ] && [ -n "$DEVICEID" ] && outputdetails
				[ -n "$tmpusername1" ] && USERNAME="$tmpusername1"
				[ -n "$tmpusername2" ] && USERNAME="$tmpusername2"
	   			DEVICEID=""
   				DEVICETYPE=""
   				USERAGENT=""
   				DEVICEMODEL=""
	   			DEVICEIMEI=""
   				DEVICENAME=""
   				DEVICEOS=""
   				DEVICEOSLANG=""
	   			DEVICEOPER=""
   				VERSION=""
   				FIRSTSYNC=""
   				LASTSYNC=""
	   			FOLDERTOTAL=""
   				FOLDERCOUNT=""
   				FOLDERS=""
   				STATUS=""
	   			WIPEREQUESTON=""
   				WIPEREQUESTBY=""
   				WIPEDON=""
   				ERRORS=""
			else
   				[ -z "$DEVICEID" ] && DEVICEID=$( echo -e "$LINE" | sed -n 's|\s*DeviceId:\s*||p' )
   				[ -z "$DEVICETYPE" ] && DEVICETYPE=$( echo -e "$LINE" | sed -n 's|\s*Device type:\s*||p' )
   				[ -z "$USERAGENT" ] && USERAGENT=$( echo -e "$LINE" | sed -n 's|\s*UserAgent:\s*||p' )
	   			[ -z "$DEVICEMODEL" ] && DEVICEMODEL=$( echo -e "$LINE" | sed -n 's|\s*Device Model:\s*||p' )
   				[ -z "$DEVICEIMEI" ] && DEVICEIMEI=$( echo -e "$LINE" | sed -n 's|\s*Device IMEI:\s*||p' )
   				[ -z "$DEVICENAME" ] && DEVICENAME=$( echo -e "$LINE" | sed -n 's|\s*Device friendly name:\s*||p' )
   				[ -z "$DEVICEOS" ] && DEVICEOS=$( echo -e "$LINE" | sed -n 's|\s*Device OS:\s*||p' )
	   			[ -z "$DEVICEOSLANG" ] && DEVICEOSLANG=$( echo -e "$LINE" | sed -n 's|\s*Device OS Language:\s*||p' )
   				[ -z "$DEVICEOPER" ] && DEVICEOPER=$( echo -e "$LINE" | sed -n 's|\s*Device Operator:\s*||p' )
   				[ -z "$VERSION" ] && VERSION=$( echo -e "$LINE" | sed -n 's|\s*ActiveSync version:\s*||p' )
   				[ -z "$FIRSTSYNC" ] && FIRSTSYNC=$( echo -e "$LINE" | sed -n 's|\s*First sync:\s*||p' )
	   			[ -z "$LASTSYNC" ] && LASTSYNC=$( echo -e "$LINE" | sed -n 's|\s*Last sync:\s*||p' )
   				[ -z "$FOLDERTOTAL" ] && FOLDERTOTAL=$( echo -e "$LINE" | sed -n 's|\s*Total folder:\s*||p' )
   				[ -z "$FOLDERCOUNT" ] && FOLDERCOUNT=$( echo -e "$LINE" | sed -n 's|\s*Synchronized folders:\s*||p' )
   				[ -z "$FOLDERS" ] && FOLDERS=$( echo -e "$LINE" | sed -n 's|\s*Synchronized data:\s*||p' )
	   			[ -z "$STATUS" ] && STATUS=$( echo -e "$LINE" | sed -n 's|\s*Status:\s*||p' )
   				[ -z "$WIPEREQUESTON" ] && WIPEREQUESTON=$( echo -e "$LINE" | sed -n 's|\s*WipeRequest on:\s*||p' )
   				[ -z "$WIPEREQUESTBY" ] && WIPEREQUESTBY=$( echo -e "$LINE" | sed -n 's|\s*WipeRequest by:\s*||p' )
   				[ -z "$WIPEDON" ] && WIPEDON=$( echo -e "$LINE" | sed -n 's|\s*Wiped on:\s*||p' )
	   			[ -n "$ERRORS" ] && ERRORS="$ERRORS\n""$LINE"
   				[ -z "$ERRORS" ] && ERRORS=$( echo -e "$LINE" | sed -n 's|\s*Attention needed:\s*||p' )
   			fi
		done
		[ -n "$USERNAME" ] && [ -n "$DEVICEID" ] && outputdetails
	fi
	[ "$OUTPUT" == "xml" ] && echo -e "</results>"
else
	case "$OUTPUT" in
	    "csv" )  [ "$HEADER" == "yes" ] && LIST="Synchronized Users,Device ID\n$LIST"
	    			 echo -e "$LIST" ;;
	    "xml" )  echo -e "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<results format=\"list\">"
	             tmp=$( echo -e "$LIST" | safe4xml | sed -e 's|,|" deviceid="|g' -e 's|^|<result username="|' -e 's|$|"/>|' )
	             echo -e "$tmp"
	             echo '</results>' ;;
	    * )      [ "$HEADER" == "yes" ] && LIST="Synchronized Users,Device ID\n$LIST"
	    			 echo -e "$LIST" | column -s "," -c 5 -t ;;
	esac
fi

exit $?
