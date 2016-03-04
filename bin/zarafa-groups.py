#!/usr/bin/env python
"""
Python program for Zarafa
"""
import argparse, re, fnmatch
import xml.etree.ElementTree as ElementTree
import subprocess
from multiprocessing import Process, Queue

args = {}
args['output'] = "text"
args['version'] = 0.3
args['group'] = ''
encoding = "utf-8"

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
  parser.add_argument('-o', '--output',
                    required=False,
                    default=args['output'],
                    choices=['text', 'csv', 'xml'],
                    help="Display output type.")
  parser.add_argument('group',
                    nargs='?',
                    default= args['group'],
                    action='store',
                    help="Group to retrieve details about.")
  args.update(vars(parser.parse_args()))
  if not args['group']: args['group'] = '*'

# Start program
if __name__ == "__main__":
  command_line_args()

  p = subprocess.Popen(['zarafa-admin', '-L'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)
  data = str(out).split("\n")[3:]
  groups = []
  for line in data:
    if line:
      tmp = str(line.split("\t")[1]).lower()
      if tmp != "everyone": groups.append(tmp)
  groups = sorted(fnmatch.filter(groups, args['group']))
  if len(groups) != 1:
    if args['output'] == "text":
      maxlen = max([ len(x) for x in groups ] + [14])
      print 'Group list based on filter ("' + args['group'] + '")'
      print str("Groups(" + str(len(groups)) + ")").center(maxlen)
      print "-"* maxlen
      print "\n".join(groups)
    elif args['output'] == "csv":
      print ",".join(groups)
    else:
      print '<?xml version="1.0" encoding="' + encoding + '"?>'
      xml = ElementTree.Element('zarafa-admin')     
      tmp = ElementTree.SubElement(xml, 'groups')
      for group in groups:
        ElementTree.SubElement(tmp, 'group', attrib={"name":group})
      print ElementTree.tostring(xml, encoding=encoding, method="xml")
  else:
    p = subprocess.Popen(['zarafa-admin', '--type', 'group', '--details', groups[0]], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)
    data = str(out).split("\n")
    users = []
    props = []
    for i in range(len(data))[::-1]:
        if not data[i]: 
            del data[i]
        else:
            if data[i][:7] == "Users (":
                users = data[i:]
                del data[i:]
            elif data[i] == "Mapped properties:":
                props = data[i:]
                del data[i:]
    del users[0:3]
    users = [(str(str(x).split('\t')[1]).lower(), ''.join(str(x).split('\t')[2:])) for x in users]

    del props[0]
    props = [(str(str(x).split('\t')[1]).lower(), ''.join(str(x).split('\t')[2:])) for x in props]
    props = { x[0]:x[1] for x in props }

    data = [ ( str(str(x).split('\t')[0]).lower().replace(" ","").replace(":",""), ''.join(str(x).split('\t')[1:]) ) for x in data ]
    data = { x[0]:x[1] for x in data }
    data.update(props)

    data["groupname"] = data.get("groupname","").lower()
    data["emailaddress"] = data.get("emailaddress","").lower()

    if args['output'] == "text":
        maxlen = max([ len(x) + 4 for x in data.keys() ] + [25])
        print "Groupname:".ljust(maxlen), data.get("groupname","")
        print "Fullname:".ljust(maxlen), data.get("fullname","")
        print "Address book:".ljust(maxlen), data.get("addressbook","")
        print "Mapped properties:"
        print "  PR_EC_ENABLED_FEATURES:".ljust(maxlen), data.get("pr_ec_enabled_features","")
        print "  PR_EC_DISABLED_FEATURES:".ljust(maxlen), data.get("pr_ec_disabled_features","")
        print "Users (" + str(len(users)) + "):"
        maxlen = max([ len(x[0]) for x in users ] + [15])
        print '  Username'.ljust(maxlen), '    Fullname'
        print '  ' + '-' * (maxlen + 16)
        for user in  users:
            print '  ' + str(user[0]).ljust(maxlen),'  ' + user[1]
    elif args['output'] == "csv":
        tmp =  data.get("groupname","")
        tmp += ',' + data.get("fullname","")
        tmp += ',' + data.get("addressbook","")
        tmp += ',' + data.get("pr_ec_enabled_features","")
        tmp += ',' + data.get("pr_ec_disabled_features","")
        tmp += ',' + ';'.join([x[0] for x in users])
        print tmp
    else:
        print '<?xml version="1.0" encoding="' + encoding + '"?>'
        xml = ElementTree.Element('zarafa-admin')           
        group = ElementTree.SubElement(xml, 'group', attrib=data)
        members = ElementTree.SubElement(group, 'users')
        for user in users:
            ElementTree.SubElement(members, 'user', attrib={"username":user[0], "fullname":user[1]})
        print ElementTree.tostring(xml, encoding=encoding, method="xml")
