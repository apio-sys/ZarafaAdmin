#!/bin/bash
username="$1"
ldapsearch -H "ldaps://i.opw.ie/" -LLLx -D "cn=ldapsearch,ou=web,ou=opw,dc=i,dc=opw,dc=ie" -w "D0n't__P@n!c?" "(sAMAccountName=$1)" accountExpires badPasswordTime badPwdCount pwdLastSet lastLogoff lastLogon lastLogonTimestamp logonCount logonHours | perl -p0e "s/\n //g" | sed -n "s|^\S*:|&|p"