#!/usr/bin/env python
"""
Python wrapper for zarafa-admin --type group --details group
"""
import argparse, textwrap, fnmatch, datetime
import xml.etree.cElementTree as ElementTree
import subprocess
from multiprocessing import Process, Queue

# Import Brandt Common Utilities
import sys, os
sys.path.append( os.path.realpath( os.path.join( os.path.dirname(__file__), "/opt/brandt/common" ) ) )
import brandt
sys.path.pop()

args = {}
args['cache'] = 15
args['output'] = 'text'
args['group'] = ''
args['delimiter'] = ""

version = 0.3
encoding = 'utf-8'

fieldmappings = (("groupname","Group Name"),("fullname","Fullname"),
                 ("emailaddress","Email Address"),("addressbook","Address Book"))

ldapfieldmappings = (("pr_ec_enabled_features","Enabled Features"),("pr_ec_disabled_features","Disabled Features"))


class customUsageVersion(argparse.Action):
  def __init__(self, option_strings, dest, **kwargs):
    self.__version = str(kwargs.get('version', ''))
    self.__prog = str(kwargs.get('prog', os.path.basename(__file__)))
    self.__row = min(int(kwargs.get('max', 80)), brandt.getTerminalSize()[0])
    self.__exit = int(kwargs.get('exit', 0))
    super(customUsageVersion, self).__init__(option_strings, dest, nargs=0)
  def __call__(self, parser, namespace, values, option_string=None):
    # print('%r %r %r' % (namespace, values, option_string))
    if self.__version:
      print self.__prog + " " + self.__version
      print "Copyright (C) 2013 Free Software Foundation, Inc."
      print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
      version  = "This program is free software: you can redistribute it and/or modify "
      version += "it under the terms of the GNU General Public License as published by "
      version += "the Free Software Foundation, either version 3 of the License, or "
      version += "(at your option) any later version."
      print textwrap.fill(version, self.__row)
      version  = "This program is distributed in the hope that it will be useful, "
      version += "but WITHOUT ANY WARRANTY; without even the implied warranty of "
      version += "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the "
      version += "GNU General Public License for more details."
      print textwrap.fill(version, self.__row)
      print "\nWritten by Bob Brandt <projects@brandt.ie>."
    else:
      print "Usage: " + self.__prog + " [options] [groupname]"
      print "Script used to find details about Zarafa groups.\n"
      print "Options:"
      options = []
      options.append(("-h, --help",              "Show this help message and exit"))
      options.append(("-v, --version",           "Show program's version number and exit"))
      options.append(("-o, --output OUTPUT",     "Type of output {text | csv | xml}"))
      options.append(("-c, --cache MINUTES",     "Cache time. (in minutes)"))
      options.append(("-d, --delimiter DELIM",   "Character to use instead of TAB for field delimiter"))
      options.append(("groupname",               "Filter to apply to groupnames."))
      length = max( [ len(option[0]) for option in options ] )
      for option in options:
        description = textwrap.wrap(option[1], (self.__row - length - 5))
        print "  " + option[0].ljust(length) + "   " + description[0]
      for n in range(1,len(description)): print " " * (length + 5) + description[n]
    exit(self.__exit)
def command_line_args():
  global args, version
  parser = argparse.ArgumentParser(add_help=False)
  parser.add_argument('-v', '--version', action=customUsageVersion, version=version, max=80)
  parser.add_argument('-h', '--help', action=customUsageVersion)
  parser.add_argument('-c', '--cache',
          required=False,
          default=args['cache'],
          type=int,
          help="Cache time. (in minutes)")
  parser.add_argument('-d', '--delimiter',
          required=False,
          default=args['delimiter'],
          type=str,
          help="Character to use instead of TAB for field delimiter")
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
  if args['delimiter']: args['delimiter'] = args['delimiter'][0]
  if not args['delimiter'] and args['output'] == "csv": args['delimiter'] = ","

def get_data():
  global args
  command = '/usr/sbin/zarafa-admin -L'
  cachefile = '/tmp/zarafa-groups.cache'    

  args['cache'] *= 60
  age = args['cache'] + 1
  try:
    age = (datetime.datetime.now() - datetime.datetime.fromtimestamp(os.stat(cachefile).st_mtime)).seconds
  except:
    pass

  if age > args['cache']:
    p = subprocess.Popen(command.split(" "), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)

    out = out.strip().split('\n')[3:]
    for c in reversed(range(len(out))):
      if out[c]:
        out[c] = out[c].strip()
        if out[c] != "Everyone": continue
      out.pop(c)
    out = sorted(out, key=lambda s: s.lower())

    f = open(cachefile, 'w')
    f.write("\n".join(out))
    f.close()
  else:
    f = open(cachefile, 'r')
    out = f.read().split('\n')
    f.close()

  # Apply groupname filter
  if args['group']:  
    for c in reversed(range(len(out))):
      if out[c] and fnmatch.fnmatch(out[c].lower(), args['group'].lower()): continue
      out.pop(c)

  return out

def zarafa_groups(groups):
  global args

  if args['output'] == 'text':
    print "Zarafa Groups (" + str(len(groups)) + ")"
    print "-" * max([len(x) for x in groups] + [13])
    print "\n".join( groups )
  elif args['output'] == 'csv':
    print "Zarafa Groups"
    print "\n".join( groups )
  else:
    xml = ElementTree.Element('groups')
    for group in groups:
      xmluser = ElementTree.SubElement(xml, "group", groupname = group)
    return xml

def zarafa_group(groupname):
  global args, ldapmapping
  command = '/usr/sbin/zarafa-admin --type group --details ' + str(groupname)

  p = subprocess.Popen(command.split(" "), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)

  out = str(out).split("\n")
  users = []
  props = []
  for i in reversed(range(len(out))):
      if not out[i]: 
          del out[i]
      else:
          if out[i][:7] == "Users (":
              users = out[i:]
              del out[i:]
          elif out[i] == "Mapped properties:":
              props = out[i:]
              del out[i:]
  del users[0:3]
    users = [(str(str(x).split('\t')[1]), ''.join(str(x).split('\t')[2:])) for x in users]

  del props[0]
  props = [(str(str(x).split('\t')[1]).lower(), ''.join(str(x).split('\t')[2:])) for x in props]
  props = { x[0]:x[1] for x in props }

  out = [ ( str(str(x).split('\t')[0]).lower().replace(" ","").replace(":",""), ''.join(str(x).split('\t')[1:]) ) for x in out ]
  data = { x[0]:x[1] for x in out }
  data.update(props)

  data["groupname"] = data.get("groupname","").lower()
  data["emailaddress"] = data.get("emailaddress","").lower()

  command = '/usr/sbin/zarafa-admin --type group --list-sendas ' + str(groupname)

  p = subprocess.Popen(command.split(" "), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)
  sendas = [ str(x).split("\t") for x in str(out).split("\n")[3:] if x ]

  if args['output'] == "text":
    if not args['delimiter']: args['delimiter'] = "*" 
    width = max( [ len(x[1]) for x in fieldmappings ] + [ len(x[1]) for x in ldapfieldmappings ] ) 
    for key, text in fieldmappings:
      print str(text + ":").ljust(width) + args['delimiter'] + data.get(key,'')
    print "Mapped properties:"
    for key, text in ldapfieldmappings:
      print str( "  " + text + ":").ljust(width) + args['delimiter'] + data.get(key,'')
    print "Users (" + str(len(users)) + "):"
    widths = [ max([ len(x[0]) for x in users ]), max([ len(x[1]) for x in users ]), max([ len(x[2]) for x in users ]) ] 
    print "  " + "Username".ljust(widths[0]) + args['delimiter'] + "Full Name".ljust(widths[1]) + args['delimiter'] + "Home Server"
    print "-" * (sum(widths) + 5)
    for user in users:
      print "  " + user[0].ljust(widths[0]) + args['delimiter'] + user[1].ljust(widths[1]) + args['delimiter'] + user[2].ljust(widths[2])

# Start program
if __name__ == "__main__":
    command_line_args()

    exitcode = 0
  # try:
    groups = get_data()
    if len(groups) == 1:
      xmldata = zarafa_group(groups[0])
    else:
      xmldata = zarafa_groups(groups)

    if args['output'] == 'xml': 
      xml = ElementTree.Element('zarafaadmin')
      xml.append(xmldata)
      print '<?xml version="1.0" encoding="' + encoding + '"?>\n' + ElementTree.tostring(xml, encoding=encoding, method="xml")

  # except ( Exception, SystemExit ) as err:
  #   try:
  #     exitcode = int(err[0])
  #     errmsg = str(" ".join(err[1:]))
  #   except:
  #     exitcode = -1
  #     errmsg = str(" ".join(err))

  #   if args['output'] != 'xml': 
  #     if exitcode != 0: sys.stderr.write( str(err) +'\n' )
  #   else:
  #     xml = ElementTree.Element('zarafaadmin')      
  #     xmldata = ElementTree.SubElement(xml, 'error', errorcode = str(exitcode) )
  #     xmldata.text = errmsg
  #     print '<?xml version="1.0" encoding="' + encoding + '"?>\n' + ElementTree.tostring(xml, encoding=encoding, method="xml")

  # sys.exit(exitcode)