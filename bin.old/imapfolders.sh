#!/bin/bash
#
#     Script to sync IMAP folders between Domino and Zarafa
#     Bob Brandt <projects@brandt.ie>
#  



VERSION=0.1

SYNCCMD='imapsync'
DOMINOHOST='dublinnotes.i.opw.ie'
ZARAFAHOST='zarafa-core.i.opw.ie'
ZARAFALDAP='mail-ldap.i.opw.ie'
DOMINOUSER=
ZARAFAUSER=
DOMINOPASS=
ZARAFAPASS=
OUTPUT='text'
CHECK=
DRY=''
FORCE=

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

formatoutput() {
	TAG="$1"
	while read line
	do
		line=$( echo "$line" | sed -e 's|^\s*||g' -e 's|\s*$||g' )
		if [ -n "$line" ]; then
			field=$( echo "$line" | sed 's|:\s.*||' | tr '[:upper:]' '[:lower:]' )
			value=$( echo "$line" | sed 's|.*:\s\+||' )
			[ "$field" == "cn" ] && CN="$value"
			if [ "$field" == "mail" ] && [ -n "$CN" ]; then
				echo "<$TAG cn=\"$CN\">$value</$TAG>"
				CN=""
			fi
		fi
	done
}

formatzarafa() {
	while read line
	do
		line=$( echo "$line" | sed -e 's|^\s*||g' -e 's|\s*$||g' )
		if [ -n "$line" ]; then
			field=$( echo "$line" | sed 's|:\s.*||' | tr '[:upper:]' '[:lower:]' )
			value=$( echo "$line" | sed 's|.*:\s\+||' )
			[ "$field" == "cn" ] && echo -n "$value"
			[ "$field" == "mail" ] && echo " ($value)"
		fi
	done	
}

usage() {
	[ "$2" == "" ] || echo -e "$2"
	echo -e "Usage: $0 [options]"
	echo -e "Options:"
	echo -e " --dominouser       User for Domino IMAP"
	echo -e " --zarafauser       User for Zarafa IMAP (if blank defaults to Domino User)"
	echo -e " --dominopass       Password for Domino IMAP"
	echo -e " --zarafapass       Password for Zarafa IMAP"
	echo -e " -c, --check        Check Usernames"
	echo -e " -d, --dry          Do nothing, just print what would be done"
	echo -e " -f, --force        Do not ask for confirmation before migration"
	echo -e " -i, --interactive  Do not ask for confirmation before migration"
	echo -e " -o, --output       How to format output (text,xml) text is default"
	echo -e " -h, --help         display this help and exit"
	echo -e " -v, --version      output version information and exit"	
	exit ${1:-0}
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
ARGS=$(getopt -o o:r:u:cdfivh -l "dominouser:,zarafauser:,dominopass:,zarafapass:,output:,user:,retries:,check,dry,force,interactive,help,version" -n "$0" -- "$@") || usage 1 " "

#Bad arguments
#[ $? -ne 0 ] && usage 1 "$0: No arguments supplied!\n"

eval set -- "$ARGS";

while /bin/true ; do
	case "$1" in
		--dominouser )        DOMINOUSER="$2" ; shift ;;
    	-u | --user )         DOMINOUSER="$2" ; shift ;;
		--zarafauser )        ZARAFAUSER="$2" ; shift ;;
		--dominopass )        DOMINOPASS="$2" ; shift ;;
		--zarafapass )        ZARAFAPASS="$2" ; shift ;;
    	-c | --check )        CHECK='check' ;;
    	-d | --dry )          DRY='--dry' ;;
    	-f | --force )        FORCE=force ;;
    	-i | --interactive )  FORCE= ;;
    	-o | --output )       [ $( echo "$2" | tr '[:upper:]' '[:lower:]' ) == "xml" ] && OUTPUT="xml" ; shift ;;
    	-h | --help )         usage 0 ;;
    	-v | --version )      version ;;
    	-- )                  shift ; break ;;
	    * )                   usage 1 "$0: Invalid argument!\n" ;;
	esac
	shift
done

# Check to see if IMAPSYNC is installed?
# If not, install it.
if ! $SYNCCMD --version > /dev/null 2>&1
then
	case $( lsb_release -a 2>&1 | sed -n 's|^Description:\s||p' ) in
		"Ubuntu 12.04.3 LTS" )
			cp /etc/apt/sources.list /etc/apt/sources.list.backup 
			echo -e "\ndeb http://ie.archive.ubuntu.com/ubuntu/ lucid universe" >> /etc/apt/sources.list
			echo -e "deb-src http://ie.archive.ubuntu.com/ubuntu/ lucid universe\n" >> /etc/apt/sources.list
			apt-get update
			apt-get install $SYNCCMD
			sed -i "s|.*lucid universe.*||g" /etc/apt/sources.list
			apt-get update
			;;
		* )	usage 1 "$0: To use this script you must have $SYNCCMD installed.\n" ;;
	esac 
fi

# Check Usernames
[ -z "$ZARAFAUSER" ] && ZARAFAUSER="$DOMINOUSER"
[ -z "$DOMINOUSER" ] && DOMINOUSER="$ZARAFAUSER"
if [ -z "$FORCE" ]; then
	[ -z "$DOMINOUSER" ] && read -ep "Please enter the Domino Username: " DOMINOUSER && echo
	[ -z "$ZARAFAUSER" ] && read -ep "Please enter the Zarafa Username: " ZARAFAUSER && echo
	[ -z "$ZARAFAUSER" ] && ZARAFAUSER="$DOMINOUSER"
	[ -z "$DOMINOUSER" ] && DOMINOUSER="$ZARAFAUSER"
fi
[ -z "$DOMINOUSER" ] || [ -z "$ZARAFAUSER" ] && usage 1 "$0: You must specify at least one Username\n"

# Verify that there is only one user that matches the usernames provided on each system
DOMINORESULTS=$( ldapsearch -h "$DOMINOHOST" -x -LLL "(&(mail=*)(|(mail=*$DOMINOUSER*)(displayName=*$DOMINOUSER*)(givenName=*$DOMINOUSER*)(sn=*$DOMINOUSER*)(cn=*$DOMINOUSER*)))" mail cn | base64convert | formatoutput "domino" )
ZARAFARESULTS=$( ldapsearch -h "$ZARAFALDAP" -x -LLL "(&(zarafaAccount=1)(mail=*)(|(mail=*$ZARAFAUSER*)(fullName=*$ZARAFAUSER*)(givenName=*$ZARAFAUSER*)(sn=*$ZARAFAUSER*)(cn=*$ZARAFAUSER*)))" mail cn | base64convert | formatoutput "zarafa" )
DOMINONUM=$( echo "$DOMINORESULTS" | sed '/^$/d' | wc -l )
ZARAFANUM=$( echo "$ZARAFARESULTS" | sed '/^$/d' | wc -l )

# What to do if there is more than one result or check
if [[ "$DOMINONUM" != 1 ]] || [[ "$ZARAFANUM" != 1 ]] || [ -n "$CHECK" ]; then
	if [ "$OUTPUT" == "xml" ]; then
		echo -e "<?xml version=\"1.0\"?>\n<results>"
		echo -e "$DOMINORESULTS"
		echo -e "$ZARAFARESULTS"
		echo -e "</results>"		
	else
		echo -e "Domino entries match the pattern ($DOMINOUSER)\n------------------------------------" > /tmp/dominoresults.$$
		echo -e "Zarafa entries match the pattern ($ZARAFAUSER)\n------------------------------------" > /tmp/zarafaresults.$$	
		echo -e "$DOMINORESULTS" | sed 's|^<domino cn="\(.*\)">\(.*\)</domino>$|\1 (\2)|' >> /tmp/dominoresults.$$
		echo -e "$ZARAFARESULTS" | sed 's|^<zarafa cn="\(.*\)">\(.*\)</zarafa>$|\1 (\2)|'>> /tmp/zarafaresults.$$
		[ -z "$CHECK" ] && echo -e "Unable to find a single username on one of the systems below:"
		paste /tmp/dominoresults.$$ /tmp/zarafaresults.$$ | column -s $'\t' -t
		rm -f /tmp/dominoresults.$$
		rm -f /tmp/zarafaresults.$$
	fi
	[ -n "$CHECK" ] && exit 0
	exit 1
fi


# Get the Login CN for each account
DOMINOUSER=$( echo "$DOMINORESULTS" | sed -e 's|.*cn="||' -e 's|">.*||' )
ZARAFAUSER=$( echo "$ZARAFARESULTS" | sed -e 's|.*cn="||' -e 's|">.*||' )
DOMINONUM=$( echo "$DOMINOUSER" | sed '/^$/d' | wc -l )
ZARAFANUM=$( echo "$ZARAFAUSER" | sed '/^$/d' | wc -l )

# What to do if there is not one result
if [[ "$DOMINONUM" != 1 ]] || [[ "$ZARAFANUM" != 1 ]]; then
	[ "$OUTPUT" == "html" ] && echo '<pre style="color:red;font-weight:bold;">'
	[[ "$DOMINONUM" != 1 ]] && echo -e "There was a problem retrieving the Domino login information for user ($DOMINOUSER)\nCommand: ldapsearch -h $DOMINOHOST -x -LLL \"(mail=$DOMINOUSER)\" cn | sed -n 's|cn:\s*||p'"
	[[ "$ZARAFANUM" != 1 ]] && echo -e "There was a problem retrieving the Zarafa login information for user ($ZARAFAUSER)\nCommand: ldapsearch -h "$ZARAFALDAP" -x -LLL \"(&(zarafaAccount=1)(mail=$ZARAFAUSER))\" cn | sed -n 's|cn:\s*||p'"
	[ "$OUTPUT" == "html" ] && echo '</pre>'
	exit 1
fi

if [ -z "$FORCE" ]; then
	[ -z "$DOMINOPASS" ] && read -esp "Please enter the Domino Password for $DOMINOUSER: " DOMINOPASS && echo
	[ -z "$ZARAFAPASS" ] && read -esp "Please enter the Zarafa Password for $ZARAFAUSER: " ZARAFAPASS && echo
	echo "This script is ready to migrate $DOMINOUSER Domino IMAP folders to $ZARAFAUSER Zarafa IMAP"
	read -ep "Would you like to continue? (Y/N) " ANSWER && echo
	ANSWER=$( echo "$ANSWER" | sed -n 's|y.*|Y|pi' )
	[ "$ANSWER" != "Y" ] && exit 0
fi

$SYNCCMD --sep1 '\' --prefix1 '' --sep2 '/'  ${DRY} \
	--noauthmd5 --justfolders --no-modules_version --logfile /var/log/imapsync \
	--regextrans2 's/Trash$/Deleted Items/' \
	--regextrans2 's/Sent$/Sent Items/' \
	--regextrans2 's/Junk$/Junk E-mail/' \
	--exclude '^Outbox$' \
	--exclude '^Public folders$' \
    --host1 ${DOMINOHOST} --user1 "${DOMINOUSER}" --password1 "${DOMINOPASS}" \
	--host2 ${ZARAFAHOST} --user2 "${ZARAFAUSER}" --password2 "${ZARAFAPASS}" -ssl2

[ "$OUTPUT" == "xml" ] && echo -e '<output>'
cat /var/log/imapsync
[ "$OUTPUT" == "xml" ] && echo -e '</output>'

exit 0
