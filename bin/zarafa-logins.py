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
args['output'] = "text"


version = 0.3
encoding = 'utf-8'

months = ('','jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec')

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
      print "Usage: " + self.__prog + " [options] [-d|-u] [FILTER]"
      print "Script used to find details about Zarafa users.\n"
      print "Options:"
      options = []
      options.append(("-h, --help",              "Show this help message and exit"))
      options.append(("-v, --version",           "Show program's version number and exit"))
      options.append(("-o, --output OUTPUT",     "Type of output {text | xml}"))
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
  parser.add_argument('-o', '--output',
                      required=False,
                      default=args['output'],
                      choices=['text', 'xml'],
                      help="Display output type.")
  args.update(vars(parser.parse_args()))

def get_data():
  global args

  command = 'grep "Authentication by plugin failed for user" "/var/log/zarafa/server.log"'
  p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)
  users = {}

  for line in out.split('\n'):
    try:
      tmp = line.replace("  "," ").replace(" ",":").split(":")
      if tmp and len(tmp) > 5:
        tmpTime = datetime.datetime( int(tmp[6]), months.index(tmp[1].lower()), int(tmp[2]), int(tmp[3]), int(tmp[4]), int(tmp[5]) )
        tmpUser = tmp[-1].lower()

        if not users.has_key(tmpUser): users[tmpUser] = {'user':tmpUser, '1m':0, '5m':0, '15m':0, '1h':0, '4h':0, '8h':0, '1d':0, '3d':0}
        now =  datetime.datetime.now()
        if tmpTime > now - datetime.timedelta(minutes = 1): users[tmpUser]['1m'] += 1
        if tmpTime > now - datetime.timedelta(minutes = 5): users[tmpUser]['5m'] += 1
        if tmpTime > now - datetime.timedelta(minutes = 15): users[tmpUser]['15m'] += 1
        if tmpTime > now - datetime.timedelta(hours = 1): users[tmpUser]['1h'] += 1
        if tmpTime > now - datetime.timedelta(hours = 4): users[tmpUser]['4h'] += 1
        if tmpTime > now - datetime.timedelta(hours = 8): users[tmpUser]['8h'] += 1
        if tmpTime > now - datetime.timedelta(days = 1): users[tmpUser]['1d'] += 1
        if tmpTime > now - datetime.timedelta(days = 3): users[tmpUser]['3d'] += 1
    except:
      pass

  attrs = "cn,samAccountName,mail,badPwdCount,badPasswordTime,lastLogon,logonHours,pwdLastSet,accountExpires,logonCount,lastLogonTimestamp"
  for user in users.keys():
    try:
      ldapURI = "ldaps://opwdc2.i.opw.ie/ou=opw,dc=i,dc=opw,dc=ie?" + attrs + "?sub?sAMAccountName=" + user
      results = brandt.LDAPSearch(ldapURI).results
      if str(results[0][1]['sAMAccountName'][0]).lower() == user.lower():
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

  return users



# Start program
if __name__ == "__main__":
  command_line_args()

  users = get_data()

  if args['output'] != "xml":
    usermaxlen = max( [ len(x) for x in users.keys() ] + [8] )

    tmp = sorted([ (d['1m'],u) for (u, d) in users.iteritems() if d['1m'] > 0 ], reverse=True)
    if tmp:
      print "Last Minute".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)

    tmp = sorted([ (d['5m'],u) for (u, d) in users.iteritems() if d['5m'] > 0 ], reverse=True)
    if tmp:
      print "Last 5 Minutes".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)


    tmp = sorted([ (d['15m'],u) for (u, d) in users.iteritems() if d['15m'] > 0 ], reverse=True)
    if tmp:
      print "Last 15 Minutes".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)


    tmp = sorted([ (d['1h'],u) for (u, d) in users.iteritems() if d['1h'] > 0 ], reverse=True)
    if tmp:
      print "Last Hour".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)


    tmp = sorted([ (d['4h'],u) for (u, d) in users.iteritems() if d['4h'] > 0 ], reverse=True)
    if tmp:
      print "Last 4 Hours".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)


    tmp = sorted([ (d['8h'],u) for (u, d) in users.iteritems() if d['8h'] > 0 ], reverse=True)
    if tmp:
      print "Last 8 Hours".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)


    tmp = sorted([ (d['1d'],u) for (u, d) in users.iteritems() if d['1d'] > 0 ], reverse=True)
    if tmp:
      print "Last Day".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)

    tmp = sorted([ (d['3d'],u) for (u, d) in users.iteritems() if d['3d'] > 0 ], reverse=True)
    if tmp:
      print "Last 3 Days".center(usermaxlen + 9)
      print "Username".ljust(usermaxlen), "  ", "Count"
      print "-" * (usermaxlen + 9) 
      for user in tmp:
        print str(user[1]).ljust(usermaxlen), "  ", str(user[0]).rjust(5)

    for user in sorted(users.keys()):
      print
      print user + ":"
      print "-" * 30
      if users[user].has_key("dn"):
        print "dn".rjust(18) + ": " +  users[user]["dn"]

      if users[user].has_key("badpwdcount"):
        print "badPwdCount".rjust(18) + ": " +  users[user]["badpwdcount"]

      if users[user].has_key("badpasswordtime"):
        print "badPasswordTime".rjust(18) + ": " +  users[user]["badpasswordtime"]

      if users[user].has_key("lastlogoff"):
        print "lastLogoff".rjust(18) + ": " +  users[user]["lastlogoff"]

      if users[user].has_key("lastlogon"):
        print "lastLogon".rjust(18) + ": " +  users[user]["lastlogon"]

      if users[user].has_key("logonhours"):
        print "logonHours".rjust(18) + ": " +  users[user]["logonhours"]

      if users[user].has_key("pwdlastset"):
        print "pwdLastSet".rjust(18) + ": " +  users[user]["pwdlastset"]

      if users[user].has_key("accountexpires"):
        print "accountExpires".rjust(18) + ": " +  users[user]["accountexpires"]

      if users[user].has_key("logoncount"):
        print "logonCount".rjust(18) + ": " +  users[user]["logoncount"]

      if users[user].has_key("lastlogontimestamp"):
        print "lastLogonTimestamp".rjust(18) + ": " +  users[user]["lastlogontimestamp"]

      if users[user].has_key("error"):
        print "Error".rjust(18) + ": " +  users[user]["error"]

  else:

    xml = ElementTree.Element('zarafaadmin')
    xmlLog = ElementTree.Element('log', log='Login Errors', filters='')
    for user in sorted(users.keys()):
      for key in ['1m','5m','15m','1h','4h','8h','1d','3d']:
        tmp = brandt.strXML(users[user].pop(key))
        users[user].update({key:tmp})
      ElementTree.SubElement(xmlLog, "user", **users[user])

    print '<?xml version="1.0" encoding="' + encoding + '"?>\n' + ElementTree.tostring(xml, encoding=encoding, method="xml")
