#!/usr/bin/env python
"""
Python program for Zarafa
"""
import argparse, textwrap, fnmatch, datetime
import xml.etree.cElementTree as ElementTree
import subprocess

# Import Brandt Common Utilities
import sys, os
sys.path.append( os.path.realpath( os.path.join( os.path.dirname(__file__), "/opt/brandt/common" ) ) )
import brandt
sys.path.pop()

args = {}
args['cache'] = 15
args['output'] = "text"
args['delimiter'] = ""

version = 0.3
encoding = 'utf-8'

months = ('','jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec')

attrsTime = { 'm1':  1,
              'm5':  5,
              'm15': 15,
              'h1':  1 * 60,
              'h4':  4 * 60,
              'h8':  8 * 60,
              'd1':  1 * 60 * 24,
              'd3':  3 * 60 * 24 }

attrsLDAP = { 'cn':'Windows Name',
              'samAccountName':'Username',
              'mail':'Email Address',
              'badPwdCount':'Bad Password Count',
              'badPasswordTime':'Bad Password Time',
              'lastLogon':'Last Logon',
              'lastlogoff':'Last Logoff',
              'logonHours':'Logon Hours',
              'pwdLastSet':'Password Last Set',
              'accountExpires':'Account Expires',
              'logonCount':'Logon Count',
              'lastLogonTimestamp':'Last Login Time' }

class customUsageVersion(argparse.Action):
  def __init__(self, option_strings, dest, **kwargs):
    self.__version = str(kwargs.get('version', ''))
    self.__prog = str(kwargs.get('prog', os.path.basename(__file__)))
    self.__row = min(int(kwargs.get('max', 80)), brandt.getTerminalSize()[0])
    self.__exit = int(kwargs.get('exit', 0))
    super(customUsageVersion, self).__init__(option_strings, dest, nargs=0)
  def __call__(self, parser, namespace, values, option_string=None):
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
      print "Usage: " + self.__prog + " [options] "
      print "Script used to find number of login errors per user.\n"
      print "Options:"
      options = []
      options.append(("-h, --help",              "Show this help message and exit"))
      options.append(("-v, --version",           "Show program's version number and exit"))
      options.append(("-o, --output OUTPUT",     "Type of output {text | csv| xml}"))
      options.append(("-c, --cache MINUTES",     "Cache time. (in minutes)"))
      options.append(("-d, --delimiter DELIM",   "Character to use instead of TAB for field delimiter"))      
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
  args.update(vars(parser.parse_args()))
  if args['delimiter']: args['delimiter'] = args['delimiter'][0]
  if not args['delimiter'] and args['output'] == "csv": args['delimiter'] = ","  

def get_data():
  global args, attrsTime, attrsLDAP
  cachefile = '/tmp/zarafa-logins.cache'    

  args['cache'] *= 60
  age = args['cache'] + 1
  try:
    age = (datetime.datetime.now() - datetime.datetime.fromtimestamp(os.stat(cachefile).st_mtime)).seconds
  except:
    pass

  if age > args['cache']:
    command = 'grep "Authentication by plugin failed for user" "/var/log/zarafa/server.log"'
    p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)
    users = {}

    for line in out.split('\n'):
      try:
        now =  datetime.datetime.now()        
        tmp = line.replace("  "," ").replace(" ",":").split(":")
        tmpTime = datetime.datetime( int(tmp[6]), months.index(tmp[1].lower()), int(tmp[2]), int(tmp[3]), int(tmp[4]), int(tmp[5]) )
        tmpUser = tmp[-1].lower()

        if not users.has_key(tmpUser): users[tmpUser] = {'user':tmp[-1]}
        for attr in attrsTime.keys():
          if tmpTime > now - datetime.timedelta(minutes = attrsTime[attr]): users[tmpUser].update( {attr: users[tmpUser].get(attr,0) + 1})

      except:
        pass

    for user in users.keys():
      if len(users[user]) == 1: del users[user]

    for user in users.keys():
      try:
        ldapURI = "ldaps://opwdc2.i.opw.ie/ou=opw,dc=i,dc=opw,dc=ie?" + ",".join(attrsLDAP.keys()) + "?sub?sAMAccountName=" + user
        results = brandt.LDAPSearch(ldapURI).results
        if str(results[0][1]['sAMAccountName'][0]).lower() == user:
          for key in results[0][1]:
            value = results[0][1][key][0]
            key = key.lower()
            if key in ['badpasswordtime','lastlogoff','lastlogon','pwdlastset','lastlogontimestamp','accountexpires']:
              value = str(datetime.datetime(1601,1,1) + datetime.timedelta(microseconds=( int(value)/10) ))[:19]
              if value == '1601-01-01 00:00:00': value = 'never'
            elif key == 'logonhours':
              tmp = ""
              for char in value:
                tmp += str(hex(ord(char))[2:]).upper()
              value = tmp
            users[user][key] = brandt.strXML(value)
      except:
        pass

    f = open(cachefile, 'w')
    for user in sorted(users.keys()):
      f.write(user)
      for attr in sorted(attrsTime, key=attrsTime.get) + sorted(attrsLDAP.keys(), key=lambda x: x.lower()):
        f.write( "," + str(users[user].get(attr,"")) )
      f.write("\n")
    f.close()
  # else:
  #   f = open(cachefile, 'r')
  #   out = f.read().split('\n')
  #   f.close()

  for user in users.keys(): print users[user]

  print 
  print 


  sys.exit(0)

  return users



# Start program
if __name__ == "__main__":
  # try:
    command_line_args()
    users = get_data()

  # except SystemExit as err:
  #   pass
  # except Exception as err:
  #   try:
  #     exitcode = int(err[0])
  #     errmsg = str(" ".join(err[1:]))
  #   except:
  #     exitcode = -1
  #     errmsg = str(err)

  #   if args['output'] != 'xml': 
  #     error = "(" + str(exitcode) + ") " + str(errmsg) + "\nCommand: " + " ".join(sys.argv)
  #   else:
  #     xmldata = ElementTree.Element('error', code=brandt.strXML(exitcode), 
  #                                            msg=brandt.strXML(errmsg), 
  #                                            cmd=brandt.strXML(" ".join(sys.argv)))

  # finally:
  #   if args['output'] != "xml":
  #     usermaxlen = max( [ len(x) for x in users.keys() ] + [8] )

  #     for label, key in [('Last Minute','1m'),('Last 5 Minutes','5m'),('Last 15 Minutes','15m'),('Last Hour','1h'),('Last 4 Hours','4h'),('Last 8 Hours','8h'),('Last Day','1d'),('Last 3 Days','3d')]:
  #       tmp = sorted([ (u, d[key]) for u, d in users.iteritems() if d.get(key, 0) > 0 ], reverse=True)
  #       if tmp:       
  #         print str(label).center(usermaxlen + 9)
  #         print "Username".ljust(usermaxlen), "  ", "Count"
  #         print "-" * (usermaxlen + 9)
  #         for user, data in sorted(tmp, key=lambda x: x[0]):
  #           print str(user).ljust(usermaxlen), "  ", str(data).rjust(5)
  #         print
          
  #     for user in sorted(users.keys()):
  #       if users[user].get('samaccountname','') and users[user].get('cn',''):
  #         print "User information for " + users[user].get('samaccountname','').lower() + " (" + users[user].get('cn','') +"):\n" + ("-" * 30)
  #         for key in sorted([ k.strip() for k in attrs.split(",") ]):
  #           if key not in ['cn','samAccountName']:
  #             print str(key).rjust(18) + ": " +  users[user].get(str(key).lower(),"")
  #         print

  #   else:

  #     xml = ElementTree.Element('zarafaadmin')
  #     xmlLog = ElementTree.SubElement(xml, 'log', log='Login Errors', filters='')
  #     for user in sorted(users.keys()):
  #       for key in ['1m','5m','15m','1h','4h','8h','1d','3d']:
  #         tmp = brandt.strXML(users[user].pop(key))
  #         users[user].update({key:tmp})
  #       ElementTree.SubElement(xmlLog, "user", **users[user])

  #     print '<?xml version="1.0" encoding="' + encoding + '"?>\n' + ElementTree.tostring(xml, encoding=encoding, method="xml")
