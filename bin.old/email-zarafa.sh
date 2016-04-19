#!/bin/bash
#
#     Script to list all Zarafa email users for a user
#     Bob Brandt <projects@brandt.ie>
#  

LDAPSERVER='mail-ldap.opw.ie'
VERSION=0.2
OUTPUT='text'
HEADER='yes'

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

usage() {
        [ "$2" == "" ] || echo -e "$2"
        echo -e "Usage: $0 [options] username"
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

echo "$OUTPUT" | grep -i "^\(text\|xml\|csv\)$" > /dev/null || usage 1 "$0: Incorrect Output Type\n"

if [ -n "$1" ]; then
	USERNAME=$@
else
	usage 1 "$0: Invalid Username\n"
fi

USERRESULTS=$( ldapsearch -h "$LDAPSERVER" -x -LLL "(&(objectClass=zarafa-user)(zarafaAccount=1)(mail=*)(cn=$USERNAME))" mail zarafaAliases | sed -e '/^$/,$d' | base64convert )
DN=$( echo -e "$USERRESULTS" | sed -n 's|^dn:\s||p' )
GROUPRESUTS=$( ldapsearch -h "$LDAPSERVER" -x -LLL "(&(objectClass=zarafa-group)(zarafaAccount=1)(mail=*)(member=$DN))" mail zarafaAliases | base64convert )
EMAILS=$( echo -e "$USERRESULTS\n$GROUPRESUTS" | sed -n -e 's|^mail:\s||p' -e 's|^zarafaAliases:\s||p' | sort -uf )

case "$OUTPUT" in
   "csv" )  echo -e "$EMAILS" | tr "\n" "," | sed "s|,$|\n|" ;;
   "xml" )  echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<results username=\"$USERNAME\">"
            echo -e "$EMAILS" | safe4xml | tr "\n" "," | sed "s|,$|\n|" | sed -e "s|,|</result><result>|g" -e "s|^|<result>|" -e "s|$|</result>|"
            echo -e '</results>' ;;
   * )      echo -e "Email addresses for $USERNAME\n------------------------\n$EMAILS" ;;
esac
