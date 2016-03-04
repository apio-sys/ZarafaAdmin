#!/usr/bin/env python

"""
Read the delegate permissions of a Zarafa mailbox
"""

import argparse, re, fnmatch
import xml.etree.ElementTree as ElementTree
import subprocess
from multiprocessing import Process, Queue


ecRightsNone            = 0x00000000
ecRightsReadAny         = 0x00000001
ecRightsCreate          = 0x00000002
ecRightsEditOwned       = 0x00000008
ecRightsDeleteOwned     = 0x00000010
ecRightsEditAny         = 0x00000020
ecRightsDeleteAny       = 0x00000040
ecRightsCreateSubfolder = 0x00000080
ecRightsFolderAccess    = 0x00000100
ecRightsFolderVisible   = 0x00000400

ecRightsFullControl     = 0x000004FBL

ecRightsTemplateNoRights    = ecRightsFolderVisible
ecRightsTemplateReadOnly    = ecRightsTemplateNoRights | ecRightsReadAny
ecRightsTemplateSecretary   = ecRightsTemplateReadOnly | ecRightsCreate | ecRightsEditOwned | ecRightsDeleteOwned | ecRightsEditAny | ecRightsDeleteAny
ecRightsTemplateOwner       = ecRightsTemplateSecretary | ecRightsCreateSubfolder | ecRightsFolderAccess

args = {}
args['version'] = 0.3

def command_line_args():
  global args

  parser = argparse.ArgumentParser(description=".",
                    formatter_class=argparse.RawDescriptionHelpFormatter)
  parser.add_argument('-v', '--version',
                    action='version',
                    version="%(prog)s " + str(args['version']) + """
  Copyright (C) 2011 Free Software Foundation, Inc.
  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
  This is free software: you are free to change and redistribute it.
  There is NO WARRANTY, to the extent permitted by law.
  Written by Bob Brandt <projects@brandt.ie>.\n """)
  args.update(vars(parser.parse_args()))



# Start program
if __name__ == "__main__":
    command_line_args()

    #p = subprocess.Popen(['zarafa-mailbox-permissions', '--list-permissions', '-a'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    p = subprocess.Popen(['cat', '/opt/opw/permissions.txt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)
    data = str(out).split("\n")
    users = {}

    for i in range(len(data))[::-1]:
        if not data[i]: 
            del data[i]
        elif data[i][:18] == 'Store information ':
            users[data[i][18:].lower()] = data[i:]
            del data[i:]
    print users.keys()