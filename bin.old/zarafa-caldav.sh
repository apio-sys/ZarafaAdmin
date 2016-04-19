#!/bin/bash
#
#     Script to list users, if there is only one user returns, also 
#      return all the objects that the user has caldav rights to.
#     Bob Brandt <projects@brandt.ie>
#  

ZARAFAUSER='sudo /opt/opw/zarafa-users.sh'
ZARAFAPERMISSIONS='sudo /opt/opw/zarafa-permissions.sh'
VERSION=0.1

usage() {
        [ "$2" == "" ] || echo -e "$2"
        echo -e "Usage: $0 [options] username"
        echo -e "Options:"
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
ARGS=$(getopt -o vh -l "help,version" -n "$0" -- "$@") || usage 1 " "

#Bad arguments
#[ $? -ne 0 ] && usage 1 "$0: No arguments supplied!\n"

eval set -- "$ARGS";

OUTPUT='text'
HEADER='yes'
USER=''
TARGET=''
FOLDER=''

while /bin/true ; do
    case "$1" in
        -h | --help )      usage 0 ;;
        -v | --version )   version ;;
        -- )               shift ; break ;;
        * )                usage 1 "$0: Invalid argument!\n" ;;
    esac
    shift
done

OBJECT="$1"

tmp=$( $ZARAFAUSER --output xml "$OBJECT" )
count=$( echo -e "$tmp" | grep "<result.*/>" | wc -l )
if [ "$count" == "1" ]; then
	echo -e "$tmp" | sed "/<\/results>/d"
	$ZARAFAPERMISSIONS --quiet --output xml "$OBJECT" '\-' | grep '<result.*>' | sed 's|.*="\(.*\)".*|<result username="\1" fullname="\1"/>|' | sed "/<results>/d"
	echo -e "</results>"
else
	echo -e "$tmp"	
fi

exit 0
