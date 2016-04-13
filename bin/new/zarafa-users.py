#!/usr/bin/env python
"""
Python wrapper for zarafa-stats --users
"""
import argparse, re, fnmatch, sys, datetime
import xml.etree.cElementTree as ElementTree
import subprocess
from multiprocessing import Process, Queue


args = {}
args['cache'] = 5
args['output'] = 'text'
args['version'] = 0.3
encoding = 'utf-8'
command = '/usr/bin/zarafa-stats --users --dump'

cachefile = '/tmp/zarafa-users.cache'

headers = ['company','username','fullname','emailaddress','active','admin','UNK0x67C1001E','size','quotawarn','quotasoft','quotahard','UNK0x67200040','UNK0x6760000B','logon','logoff']
#headers['session'] = ['UNK0x67420014','UNK0x674D0014','ip','UNK0x67440003','UNK0x67450003','UNK0x6746000B','username','UNK0x6747101E','UNK0x6749101E','UNK0x674A0005','UNK0x674B0005','UNK0x674C0005','UNK0x674E0003','version','program','UNK0x67510003','UNK0x67480003','UNK0x6753001E','pipe']
#headers['system'] = ['parameter','description','value']

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

    p = subprocess.Popen(command.split(" "), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)

    if args['output'] == 'text':
        print out
    elif args['output'] == 'csv':
        print ";".join(headers)
        print "\n".join(out.split('\n')[1:])
    else:
        xml = ElementTree.Element('zarafa-stats')
        if args['command'] == 'system':
            cmd = ElementTree.SubElement(xml, "system")
            for line in out.split('\n')[1:]:
                if not line: continue                
                try:
                    tag, desc, value = line.split(';')
                    child = ElementTree.SubElement(cmd,tag, description=desc)
                    child.text = str(value).decode('unicode_escape')
                except:
                    pass                
        else:
            if args['command'] == 'session':
                cmd = ElementTree.SubElement(xml, "sessions")
            else:
                cmd = ElementTree.SubElement(xml, "users")
            for line in out.split('\n')[1:]:
                if not line: continue
                tmp = line.split(';')
                if args['command'] == 'session':
                    subcmd = ElementTree.SubElement(cmd, "session")
                else:
                    subcmd = ElementTree.SubElement(cmd, "user")
                for i in range(len(tmp)):
                    try:
                        if tmp[i] and headers[args['command']][i] in ['logon','logoff']:
                            today = datetime.datetime.today()
                            date = datetime.datetime.strptime(tmp[i].decode('unicode_escape'),'%a %b %d %H:%M:%S %Y')
                            child = ElementTree.SubElement(subcmd, headers[args['command']][i], lag=str((today - date).days))
                        else:
                            child = ElementTree.SubElement(subcmd, headers[args['command']][i])
                        child.text = tmp[i].decode('unicode_escape')
                    except:
                        pass

        print '<?xml version="1.0" encoding="' + encoding + '"?>'
        print ElementTree.tostring(xml, encoding=encoding, method="xml")
