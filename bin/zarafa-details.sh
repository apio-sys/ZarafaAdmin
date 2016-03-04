#!/bin/bash
#
#     Script to list users details
#     Bob Brandt <projects@brandt.ie>
#

ZARAFAADMINCMD='/usr/sbin/zarafa-admin'
ZARAFAHOST='zarafa-core.i.opw.ie'
ZARAFALDAP='i.opw.ie'
VERSION=0.2
OUTPUT='text'
HEADER='yes'
LDAPFILTER=
ONLY=


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


userdetail() {
   USERNAME=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Username:\s*||p' )
   FULLNAME=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Fullname:\s*||p' )
   EMAIL=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Emailaddress:\s*||p' )
   ACTIVE=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Active:\s*||p' )
   ADMIN=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Administrator:\s*||p' )
   VISIBLE=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Address book:\s*||p' )
   AUTOACCEPT=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Auto-accept meeting req:\s*||p' )
   LOGON=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Last logon:\s*||p' )
   LOGOFF=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Last logoff:\s*||p' )
   PR_GIVEN_NAME=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_GIVEN_NAME\s*||p' )
   PR_BUSINESS_TELEPHONE_NUMBER=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_BUSINESS_TELEPHONE_NUMBER\s*||p' )
   PR_SURNAME=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_SURNAME\s*||p' )
   PR_TITLE=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_TITLE\s*||p' )
   PR_DEPARTMENT_NAME=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_DEPARTMENT_NAME\s*||p' )
   PR_OFFICE_LOCATION=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_OFFICE_LOCATION\s*||p' )
   PR_MOBILE_TELEPHONE_NUMBER=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_MOBILE_TELEPHONE_NUMBER\s*||p' )
   PR_PRIMARY_FAX_NUMBER=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*PR_PRIMARY_FAX_NUMBER\s*||p' )   
   QUOTA=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Quota overrides:\s*||p' )
   WARNINGLEVEL=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Warning level:\s*||p' )
   SOFTLEVEL=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Soft level:\s*||p' )
   HARDLEVEL=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Hard level:\s*||p' )
   CURRENTSIZE=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Current store size:\s*||p' )
   GROUP=$( echo "$ZARAFAADMINOUTPUT" | grep -iA 9999 "Groups" | sed -e '/^$/d' )
   GROUPLABEL=$( echo "$GROUP" | head -n 1 )
   declare -i GROUPCOUNT=$( echo -n "$GROUP" | wc -l )
    
   GROUPLIST=
   for ITEM in $( echo "$GROUP" | tail -n $GROUPCOUNT ); do
   	ITEM=$( echo "$ITEM" | sed 's|\s*||' )
      if [ -z "$GROUPLIST" ]; then
			GROUPLIST="$ITEM"      	
      else
      	GROUPLIST="$GROUPLIST,$ITEM"
      fi
   done

	case "$OUTPUT" in
   	"xml" )	echo -en "<user"
					echo -en " username=\"$( trim "$USERNAME" | safe4xml )\""
				   echo -en " fullname=\"$( trim "$FULLNAME" | safe4xml )\""
				   echo -en " email=\"$( trim "$EMAIL" | safe4xml )\""
				   echo -en " active=\"$( trim "$ACTIVE" | safe4xml )\""
				   echo -en " admin=\"$( trim "$ADMIN" | safe4xml )\""
				   echo -en " visible=\"$( trim "$VISIBLE" | safe4xml )\""
				   echo -en " autoaccept=\"$( trim "$AUTOACCEPT" | safe4xml )\""
				   echo -en " logon=\"$( trim "$LOGON" | safe4xml )\""
				   echo -en " logoff=\"$( trim "$LOGOFF" | safe4xml )\""
				   echo -en " givenname=\"$( trim "$PR_GIVEN_NAME" | safe4xml )\""
				   echo -en " telephone=\"$( trim "$PR_BUSINESS_TELEPHONE_NUMBER" | safe4xml )\""
				   echo -en " surname=\"$( trim "$PR_SURNAME" | safe4xml )\""
				   echo -en " title=\"$( trim "$PR_TITLE" | safe4xml )\""
				   echo -en " department=\"$( trim "$PR_DEPARTMENT_NAME" | safe4xml )\""
				   echo -en " location=\"$( trim "$PR_OFFICE_LOCATION" | safe4xml )\""
				   echo -en " mobile=\"$( trim "$PR_MOBILE_TELEPHONE_NUMBER" | safe4xml )\""
				   echo -en " fax=\"$( trim "$PR_PRIMARY_FAX_NUMBER" | safe4xml )\""
				   echo -en " quota=\"$( trim "$QUOTA" | safe4xml )\""
				   echo -en " warning=\"$( trim "$WARNINGLEVEL" | safe4xml )\""
				   echo -en " soft=\"$( trim "$SOFTLEVEL" | safe4xml )\""
				   echo -en " hard=\"$( trim "$HARDLEVEL" | safe4xml )\""
				   echo -en " size=\"$( trim "$CURRENTSIZE" | safe4xml )\""
               echo -en ">"
            	echo -en "<groups count=\"$GROUPCOUNT\">"
					for ITEM in $( echo "$GROUP" | tail -n $GROUPCOUNT ); do
						echo -en "<group groupname=\"$( trim "$ITEM" | safe4xml )\"/>"
					done
					echo -en "</groups>"
   				echo -e "</user>" ;;
      "csv" )	[ -z "$ONLY" ] && echo -en "User,"
      			echo -en $( trim "$USERNAME" | safe4csv )
				   echo -en ",$( trim "$FULLNAME" | safe4csv )"
				   echo -en ",$( trim "$EMAIL" | safe4csv )"
				   echo -en ",$( trim "$ACTIVE" | safe4csv )"
				   echo -en ",$( trim "$ADMIN" | safe4csv )"
				   echo -en ",$( trim "$VISIBLE" | safe4csv )"
				   echo -en ",$( trim "$AUTOACCEPT" | safe4csv )"
				   echo -en ",$( trim "$LOGON" | safe4csv )"
				   echo -en ",$( trim "$LOGOFF" | safe4csv )"
				   echo -en ",$( trim "$PR_GIVEN_NAME" | safe4csv )"
				   echo -en ",$( trim "$PR_BUSINESS_TELEPHONE_NUMBER" | safe4csv )"
				   echo -en ",$( trim "$PR_SURNAME" | safe4csv )"
				   echo -en ",$( trim "$PR_TITLE" | safe4csv )"
				   echo -en ",$( trim "$PR_DEPARTMENT_NAME" | safe4csv )"
				   echo -en ",$( trim "$PR_OFFICE_LOCATION" | safe4csv )"
				   echo -en ",$( trim "$PR_MOBILE_TELEPHONE_NUMBER" | safe4csv )"
				   echo -en ",$( trim "$PR_PRIMARY_FAX_NUMBER" | safe4csv )"
				   echo -en ",$( trim "$QUOTA" | safe4csv )"
				   echo -en ",$( trim "$WARNINGLEVEL" | safe4csv )"
				   echo -en ",$( trim "$SOFTLEVEL" | safe4csv )"
				   echo -en ",$( trim "$HARDLEVEL" | safe4csv )"
				   echo -en ",$( trim "$CURRENTSIZE" | safe4csv )"
				   echo -e ",$( trim "$GROUPLIST" )" ;;
   	* )		[ "$HEADER" == "yes" ] && echo -e "\nZarafa User Information for $FULLNAME\n--------------------------------------------------"
   	       ( echo -e "Username:,$USERNAME"
				   echo -e "Fullname:,$FULLNAME"
				   echo -e "Email:,$EMAIL"
				   echo -e "Active:,$ACTIVE"
				   echo -e "Administrator:,$ADMIN"
				   echo -e "Visible:,$VISIBLE"
				   echo -e "Auto-accept meetings:,$AUTOACCEPT"
				   echo -e "Last logon:,$LOGON"
				   echo -e "Last logoff:,$LOGOFF"
				   echo -e "LDAP mapped properties"
				   echo -e " Given name:,$PR_GIVEN_NAME"
				   echo -e " Telephone:,$PR_BUSINESS_TELEPHONE_NUMBER"
				   echo -e " Surname:,$PR_SURNAME"
				   echo -e " Title,$PR_TITLE"
				   echo -e " Section:,$PR_DEPARTMENT_NAME"
				   echo -e " Location:,$PR_OFFICE_LOCATION"
				   echo -e " Mobile:,$PR_MOBILE_TELEPHONE_NUMBER"
				   echo -e " Fax:,$PR_PRIMARY_FAX_NUMBER"
				   echo -e "Quota settings"
				   echo -e " Quota overrides:,$QUOTA"
				   echo -e " Warning level:,$WARNINGLEVEL"
				   echo -e " Soft level:,$SOFTLEVEL"
				   echo -e " Hard level:,$HARDLEVEL"
				   echo -e " Current store size:,$CURRENTSIZE"
				   echo -en "$GROUPLABEL,"
				   echo -e "$GROUPLIST" | sed "s|,|\n ,|g" ) | column -s "," -c 2 -t ;;
   esac
}


groupdetail() {
   GROUPNAME=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Groupname:\s*||p' )
   FULLNAME=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Fullname:\s*||p' )
   EMAIL=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Emailaddress:\s*||p' )
   VISIBLE=$( echo "$ZARAFAADMINOUTPUT" | sed -n -e 's|\s*Address book:\s*||p' )
   USERORIG=$( echo "$ZARAFAADMINOUTPUT" | grep -iA 9999 "Users" | sed -e '/^$/d' )
   USERLABEL=$( echo "$USERORIG" | head -n 1 )
	USER=$( trim "$USERORIG" | awk 'NR > 3 { print }' | sort | tr -s "\t" )
   declare -i USERCOUNT=$( echo -e "$USERLABEL"  | sed -e 's|.*(||' -e 's|).*||' )
   
	case "$OUTPUT" in
   	"xml" )	echo -en "<group"
					echo -en " groupname=\"$( trim "$GROUPNAME" | safe4xml )\""
				   echo -en " fullname=\"$( trim "$FULLNAME" | safe4xml )\""
				   echo -en " email=\"$( trim "$EMAIL" | safe4xml )\""
				   echo -en " visible=\"$( trim "$VISIBLE" | safe4xml )\">"
               echo -en "<users count=\"$USERCOUNT\">"
				   for ITEM in $( echo -e "$USER" ); do
				   	ITEM=$( trim "$ITEM" | tr -s "\t" | safe4xml )
				   	USERNAME=$( echo -e "$ITEM" | cut -d$'\t' -f1 )
				   	FULLNAME=$( echo -e "$ITEM" | cut -d$'\t' -f2 )
				   	HOMESERVER=$( echo -e "$ITEM" | cut -d$'\t' -f3 )
						echo -en "<user username=\"$( trim "$USERNAME" )\" fullname=\"$( trim "$FULLNAME" )\" homeserver=\"$( trim "$HOMESERVER" )\"/>"
				   done
					echo -e '</users></group>' ;;
      "csv" )	[ -z "$ONLY" ] && echo -en "Group,"
      			echo -en $( trim "$GROUPNAME" | safe4csv )
				   echo -en "," ; echo -en $( trim "$FULLNAME" | safe4csv )
				   echo -en "," ; echo -en $( trim "$EMAIL" | safe4csv )
					[ -z "$ONLY" ] && echo -en ",,"				   				   
				   echo -en "," ; echo -en $( trim "$VISIBLE" | safe4csv )
					[ -z "$ONLY" ] && echo -en ",,,,,,,,,,,,,,,,"				   				   				   
				   echo -e ",$USER" | cut -f1 | tr "\n" "," | sed "s|,$||" 
				   echo ;;
   	* )		[ "$HEADER" == "yes" ] && echo -e "\nZarafa Group Information for $FULLNAME\n--------------------------------------------------"
   	       ( echo -e "Groupname:,$GROUPNAME"
				   echo -e "Fullname:,$FULLNAME"
				   echo -e "Emailaddress:,$EMAIL"
				   echo -e "Visible:,$VISIBLE" ) | column -s "," -c 2 -t
					echo -e "$USERORIG" ;;
   esac
}

usage() {
        [ "$2" == "" ] || echo -e "$2"
        echo -e "Usage: $0 [options] username"
        echo -e "Options:"
        echo -e " -o, --output    how to format output (text,xml,csv) text is default"
        echo -e " -n, --noheader  do not display a header row"
        echo -e " -u, --user      only show users"
        echo -e " -g, --group     only show groups"
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
ARGS=$(getopt -o o:f:ugnvh -l "output:,fields:,user,group,noheader,help,version" -n "$0" -- "$@") || usage 1 " "

#Bad arguments
#[ $? -ne 0 ] && usage 1 "$0: No arguments supplied!\n"

eval set -- "$ARGS";

while /bin/true ; do
    case "$1" in
        -o | --output )    OUTPUT=$( echo "$2" | tr '[:upper:]' '[:lower:]' ) ; shift ;;
             --noheader )  HEADER= ;;
        -u | --user )      ONLY="zarafa-user" ;;
        -g | --group )     ONLY="zarafa-group" ;;
        -f | --fields )    FIELDFILTER=$( echo "$2" | tr '[:upper:]' '[:lower:]' ) ; shift ;;
        -h | --help )      usage 0 ;;
        -v | --version )   version ;;
        -- )               shift ; break ;;
        * )                usage 1 "$0: Invalid argument!\n" ;;
    esac
    shift
done

echo "$OUTPUT" | grep -i "^\(text\|csv\|xml\)$" > /dev/null || usage 1 "$0: Incorrect Output Type\n"

LDAPFILTER="$1"
if echo "$LDAPFILTER" | grep -i "=" > /dev/null ; then
	LDAPFILTER="(&(zarafaAccount=1)(mail=*)($LDAPFILTER))"
elif echo "$LDAPFILTER" | grep -i "*" > /dev/null ; then
	LDAPFILTER="(&(zarafaAccount=1)(mail=*)(|(mail=$LDAPFILTER)(fullName=$LDAPFILTER)(givenName=$LDAPFILTER)(sn=$LDAPFILTER)(cn=$LDAPFILTER)))"
elif [ -z "$LDAPFILTER" ]; then 
	LDAPFILTER="(&(zarafaAccount=1)(mail=*))"
else
	LDAPFILTER="(&(zarafaAccount=1)(mail=*)(|(mail=$LDAPFILTER)(cn=$LDAPFILTER)))"
fi
[ -n "$ONLY" ] && LDAPFILTER="(&(objectClass=$ONLY)$LDAPFILTER)"


RESULTS=$( ldapsearch -h "$ZARAFALDAP" -x -LLL "$LDAPFILTER" cn objectClass | base64convert | sed -n -e 's|$|,|' -e 's|^cn|&|p' -e 's|objectclass:\szarafa|&|Ip' | tr -d "\n" )
RESULTS=$( echo -e "$RESULTS" | sed -e 's|,objectClass:|\nobjectClass:|Ig' -e 's|,$||g' | sed -e 's|^objectClass:\szarafa-||' -e 's|,cn:\s|\t|' )

if [ -z "$RESULTS" ]; then
    usage 2 "$0: Invalid username or group!\n"
else
	IFS_OLD=$IFS
	IFS=$'\n'
	[ "$OUTPUT" == "xml" ] && echo -e "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<results>"
	if [ "$OUTPUT" == "csv" ] && [ "$HEADER" == "yes" ]; then
		case "$ONLY" in
			"zarafa-group" ) echo -e "Groupname,Fullname,Email,Visible,Users" ;;
			"zarafa-user" )  echo -e "Username,Fullname,Email,Active,Administrator,Visible,Auto-accept,Logon,Logoff,GivenName,Telephone,Surname,Title,Section,Location,Mobile,Fax,QuotaOverrides,QuotaWarning,QuotaSoft,QuotaHard,CurrentSize,Groups" ;;
			* )              echo -e "Type,Name,Fullname,Email,Active,Administrator,Visible,Auto-accept,Logon,Logoff,GivenName,Telephone,Surname,Title,Section,Location,Mobile,Fax,QuotaOverrides,QuotaWarning,QuotaSoft,QuotaHard,CurrentSize,Users/Groups" ;;
      esac
	fi	
	for RESULT in $( echo -e "$RESULTS" ); do
		TYPE=$( echo -e "$RESULT" | cut -f 1 )
		DETAIL=$( echo -e "$RESULT" | cut -f 2 )
		if ZARAFAADMINOUTPUT=$( $ZARAFAADMINCMD --type "$TYPE" --details "$DETAIL" | sed -e '/^$/d' ); then
		
		test "$TYPE" == "user" && userdetail
		test "$TYPE" == "group" && groupdetail
		fi		
	done
	[ "$OUTPUT" == "xml" ] && echo "</results>"
fi

exit 0




































