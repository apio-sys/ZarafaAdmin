#!/bin/bash
#
#     Script to list Mailboxes that a user has rights to
#     Bob Brandt <projects@brandt.ie>
#

ZARAFAADMIN='/usr/sbin/zarafa-admin'
ZARAFAUSER='/opt/opw/zarafa-users.sh'
ZARAFADETAILS='/opt/opw/zarafa-details.sh'
ZARAFAMAILBOXPERMISSIONS='/usr/sbin/zarafa-mailbox-permissions'
VERSION=0.1


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

zarafa-user-groups() {
	$ZARAFAADMIN -l | tail -n+5 | sed -e "s|^\s*||" -e "/^$/d" -e "s|\s\+|,|"
	$ZARAFAADMIN -L | tail -n+4 | sed -e "s|^\s*||" -e "/^$/d" -e "s|$|,|"
}

mailbox-permission() {
	object="$1"
	tmp=$( $ZARAFAMAILBOXPERMISSIONS --list-permissions "$object" )
	IFS=$'\n'
	start=
	folderpath=
	folder=
	for line in $( echo -e "$tmp" )
	do
		echo "$line" | grep -i "^Folder permissions:" > /dev/null && start="yes"
		if [ -n "$start" ] && echo "$line" | grep -i "^|    " > /dev/null
		then
			permissions=$( echo -e "$line" | cut -d "|" -f 3 | sed -e "s|^\s*||" -e "s|\s*$||" -e "s|, |,|g" )
			folder=$( echo -e "$line" | cut -d "|" -f 2 | sed "s|\s*$||" )
			declare -i depth=$(( $( echo -ne "$folder" | sed "s|^\(\s*\)\S.*|\1|" | wc -c ) - 4 ))
			folder=$( echo -e "$folder" | sed "s|^\s*||" )

			if [[ $depth < 1 ]]; then
				folderpath=
			elif [[ $depth > 0 ]]; then
				folderpath=$( echo "$folderpath" | cut -d "|" -f -$depth )
				folderpath="$folderpath|"
			fi
			folder="$folderpath$folder"
			folderpath="$folder|"
			if [ -n "$permissions" ]; then
				echo -e "$object,"$( echo "$folder" | safe4csv )",$permissions"
			fi
		fi
	done
}

mailbox-permissions() {
	OBJECTS="$1"
	IFS=$'\n'
	for object in $( echo -e "$OBJECTS" ); do
		 $0 --output csv --noheader "$object"
	done
}


usage() {
        [ "$2" == "" ] || echo -e "$2"
        echo -e "Usage: $0 [options] username"
        echo -e "Options:"
        echo -e " -t, --target    target filter"
        echo -e " -o, --output    how to format output (text,xml,csv) text is default"
        echo -e " -n, --noheader  do not display a header row"
        echo -e "     --calendar  only consider the user's calendar"
        echo -e "     --tasks     only consider the user's tasks"
        echo -e "     --caldav    only consider the user's calendar and tasks"        
        echo -e "     --inbox     only consider the user's inbox"
        echo -e "     --contacts  only consider the user's contacts"
        echo -e "     --notes     only consider the user's notes"
        echo -e "     --journal   only consider the user's journal"
        echo -e " -q, --quiet     be quiet"
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
ARGS=$(getopt -o t:o:nqvh -l "target:,output:,calendar,tasks,caldav,contacts,inbox,notes,journal,noheader,quiet,help,version" -n "$0" -- "$@") || usage 1 " "

#Bad arguments
#[ $? -ne 0 ] && usage 1 "$0: No arguments supplied!\n"

eval set -- "$ARGS";

OUTPUT='text'
HEADER='yes'
USER=''
TARGET=''
FOLDER=''
QUIET=

while /bin/true ; do
    case "$1" in
        -t | --target )    TARGET="$2" ; shift ;;
             --calendar )  FOLDER=',calendar,' ;;
             --tasks )     FOLDER=',tasks,' ;;
             --caldav )    FOLDER=',calendar,|,tasks,' ;;
             --inbox )     FOLDER=',inbox,' ;;
             --contacts )  FOLDER=',contacts,' ;;
             --notes )     FOLDER=',notes,' ;;
             --journal )   FOLDER=',journal,' ;;
        -o | --output )    OUTPUT=$( echo "$2" | tr '[:upper:]' '[:lower:]' ) ; shift ;;
        -n | --noheader )  HEADER= ;;
        -q | --quiet )     QUIET=1 ;;
        -h | --help )      usage 0 ;;
        -v | --version )   version ;;
        -- )               shift ; break ;;
        * )                usage 1 "$0: Invalid argument!\n" ;;
    esac
    shift
done
USER="$1"
TARGET="$2"

echo "$OUTPUT" | grep -i "^\(text\|csv\|xml\)$" > /dev/null || usage 1 "$0: Incorrect Output Type\n"

[ -z "$USER" ] && usage 1 "Invalid username\n"

tmp=$( $ZARAFAUSER --noheader --output csv "$USER" )
[ $( echo -e "$tmp" | sed "/^$/d" | wc -l ) -eq 0 ] && usage 1 "Invalid username\n"
[ $( echo -e "$tmp" | sed "/^$/d" | wc -l ) -gt 1 ] && usage 1 "Too many username matches\n"
USER=$( echo -e "$tmp" | cut -d "," -f 1 )

if [ -z "$TARGET" ]; then
	CONVERSION=$( zarafa-user-groups | sort -u )
	tmp=$( mailbox-permission "$USER" | grep -Ei "$FOLDER" )

	IFS=$'\n'
	for name in $( echo -e "$tmp"  | sed "s|\(\,[^:]*\:\)|\1\n|g" | sed -n "s|.*,\(.*\):|\1|p" )
	do
		username=$( echo -e "$CONVERSION" | sed -n "s|,$name.*||p" )
		[ -n "$username" ] && tmp=$( echo -e "$tmp" | sed "s|,$name:|,$username:|" )
	done

	case "$OUTPUT" in
		"csv" )	[ "$HEADER" == "yes" ] && echo -e "Object,Folder,Permissions (object:rights)"
				echo -e "$tmp" ;;
		"xml" )	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<results>"
				username=$( echo -e "$tmp" | head -1 | cut -d "," -f 1 )
				echo -e "<result object=\"$username\">"
				echo -e "$tmp" | cut -d "," -f 2- | safe4xml  | sed -e "s|^|<folder name=\"|" -e "s|,|\"><permission object=\"|" -e "s|,|\"/><permission object=\"|g" -e "s|:|\" rights=\"|g" -e "s|$|/><folder>|"
				echo -e "</result>"
				echo -e "</results>" ;;
		* )    	[ "$HEADER" == "yes" ] && tmp="Object,Folder,,Permissions (object:rights)\n--------,--------,-----------\n$tmp"
				echo -e "$tmp" | column -s "," -c 2 -t ;;
	esac
else
	tmp=$( $ZARAFAUSER --noheader --output csv "$TARGET" )
	count=$( echo -e "$tmp" | sed "/^$/d" | wc -l )
	[ $count -eq 0 ] && usage 1 "Invalid target_filter\n"
	TARGET=$( echo -e "$tmp" | cut -d "," -f 1 )
	[ -z "$QUIET" ] && echo "This may take awhile, recursively searching $count objects..." >&2

	tmp=$( $ZARAFADETAILS --noheader --output csv "$USER" )
	USERGROUPS=$( echo -e "$tmp" | cut -d "," -f 24- | sed -e "s|^,||" -e "s|,$||" )

	tmp=$( mailbox-permissions "$TARGET" | grep -Ei "$FOLDER" )

	MATCH=$( echo -e "$USER,$USERGROUPS" | sed -e "s|,$||" -e "s|\s*,\s*|,|g" -e "s/,/|/g" )
	tmp=$( echo -e "$tmp" | grep -iE "$MATCH" )

	case "$OUTPUT" in
		"csv" )	[ "$HEADER" == "yes" ] && echo -e "Object,Folder,Permissions (object:rights)"
				echo -e "$tmp" ;;
		"xml" )	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<results>"
				IFS=$'\n'
				object=
				for line in $( echo -e "$tmp" ); do
					tmp=$( echo -e "$line" | cut -d "," -f 1 )
					if [ "$tmp" != "$object" ]; then
						[ -n "$object" ] && echo -e "</result>"
						object="$tmp"
						echo -e "<result object=\"$object\">"
					fi
					echo -e "$line" | cut -d "," -f 2- | safe4xml  | sed -e "s|^|<folder name=\"|" -e "s|,|\"><permission object=\"|" -e "s|,|\"/><permission object=\"|g" -e "s|:|\" rights=\"|g" -e "s|$|/><folder>|"
				done
				[ -n "$object" ] && echo -e "</result>"
				echo -e "</results>" ;;
		* )    	[ "$HEADER" == "yes" ] && tmp="Object,Folder,,Permissions (object:rights)\n--------,--------,-----------\n$tmp"
				echo -e "$tmp" | column -s "," -c 2 -t ;;
	esac

fi

exit 0
