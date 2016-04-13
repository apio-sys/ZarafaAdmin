#!/usr/bin/env python
"""
Python wrapper for zarafa-stats --users
"""
import argparse, textwrap, re, fnmatch, datetime, time
import xml.etree.cElementTree as ElementTree
import subprocess
from multiprocessing import Process, Queue

# Import Brandt Common Utilities
import sys, os
sys.path.append( os.path.realpath( os.path.join( os.path.dirname(__file__), "/opt/brandt/common" ) ) )
import brandt
sys.path.pop()

args = {}
args['cache'] = 5
args['output'] = 'text'
version = 0.3
encoding = 'utf-8'
command = '/usr/bin/zarafa-stats --users --dump'

cachefile = '/tmp/zarafa-users.cache'

headers = ['company','username','fullname','emailaddress','active','admin','UNK0x67C1001E','size','quotawarn','quotasoft','quotahard','UNK0x67200040','UNK0x6760000B','logon','logoff']
#headers['session'] = ['UNK0x67420014','UNK0x674D0014','ip','UNK0x67440003','UNK0x67450003','UNK0x6746000B','username','UNK0x6747101E','UNK0x6749101E','UNK0x674A0005','UNK0x674B0005','UNK0x674C0005','UNK0x674E0003','version','program','UNK0x67510003','UNK0x67480003','UNK0x6753001E','pipe']
#headers['system'] = ['parameter','description','value']


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
      print "Usage: " + self.__prog + " [options] {find | restore} USER"
      print "Script used to find details about Zarafa users.\n"
      print "Options:"
      options = []
      options.append(("-h, --help",              "Show this help message and exit"))
      options.append(("-v, --version",           "Show program's version number and exit"))
      options.append(("-o, --output OUTPUT",     "Type of output {text | csv | xml}"))
      options.append(("-c, --cache MINUTES",     "Cache time. (in minutes)"))
      length = max( [ len(option[0]) for option in options ] )
      for option in options:
        description =  textwrap.wrap(option[1], (self.__row - length - 5))
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
  parser.add_argument('-o', '--output',
                    required=False,
                    default=args['output'],
                    choices=['text', 'csv', 'xml'],
                    help="Display output type.")  
  args.update(vars(parser.parse_args()))

# Start program
if __name__ == "__main__":
    command_line_args()

    args['cache'] *= 60
    age = args['cache'] + 1
    try:
        age = (datetime.datetime.now() - datetime.datetime.fromtimestamp(os.stat(cachefile).st_mtime)).seconds
    except:
        pass
    print age

    if age > args['cache']:
        p = subprocess.Popen(command.split(" "), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = p.communicate()
        if err: raise IOError(err)
        f = open(cachefile, 'w')
        f.write(out)
        f.close()

    f = open(cachefile, 'r')
    out = f.read()
    f.close()

    print out
    
    # if args['output'] == 'text':
    #     print out
    # elif args['output'] == 'csv':
    #     print ";".join(headers)
    #     print "\n".join(out.split('\n')[1:])
    # else:
    #     xml = ElementTree.Element('zarafa-stats')
    #     if args['command'] == 'system':
    #         cmd = ElementTree.SubElement(xml, "system")
    #         for line in out.split('\n')[1:]:
    #             if not line: continue                
    #             try:
    #                 tag, desc, value = line.split(';')
    #                 child = ElementTree.SubElement(cmd,tag, description=desc)
    #                 child.text = str(value).decode('unicode_escape')
    #             except:
    #                 pass                
    #     else:
    #         if args['command'] == 'session':
    #             cmd = ElementTree.SubElement(xml, "sessions")
    #         else:
    #             cmd = ElementTree.SubElement(xml, "users")
    #         for line in out.split('\n')[1:]:
    #             if not line: continue
    #             tmp = line.split(';')
    #             if args['command'] == 'session':
    #                 subcmd = ElementTree.SubElement(cmd, "session")
    #             else:
    #                 subcmd = ElementTree.SubElement(cmd, "user")
    #             for i in range(len(tmp)):
    #                 try:
    #                     if tmp[i] and headers[args['command']][i] in ['logon','logoff']:
    #                         today = datetime.datetime.today()
    #                         date = datetime.datetime.strptime(tmp[i].decode('unicode_escape'),'%a %b %d %H:%M:%S %Y')
    #                         child = ElementTree.SubElement(subcmd, headers[args['command']][i], lag=str((today - date).days))
    #                     else:
    #                         child = ElementTree.SubElement(subcmd, headers[args['command']][i])
    #                     child.text = tmp[i].decode('unicode_escape')
    #                 except:
    #                     pass

    #     print '<?xml version="1.0" encoding="' + encoding + '"?>'
    #     print ElementTree.tostring(xml, encoding=encoding, method="xml")
