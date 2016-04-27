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
  pass

# Start program
if __name__ == "__main__":
  command_line_args()

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

  print users
  sys.exit(0)



  for user in users.keys():
    p = subprocess.Popen(['/opt/opw/zarafa-logins.sh',user], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: users[user]['error'] = err
    for line in out.split('\n'):
      try:
        key, value = line.split(':',1)
        key = str(key).strip().lower()
        value = value.strip()
        if key in ['badpasswordtime','lastlogoff','lastlogon','pwdlastset','lastlogontimestamp','accountexpires']:
          value = datetime.datetime(1601,1,1) + datetime.timedelta(microseconds=( int(value)/10) )
        if key in ['logonhours'] and value[0:2] == ": ":
          value = value[2:]
        users[user][key] = str(value)
      except:
        pass


  if args['output'] == "text":
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

  if args['output'] == "xml":
    print '<?xml version="1.0" encoding="' + encoding + '"?>'
    xml = ElementTree.Element('zarafa-admin')           
    tmp = ElementTree.SubElement(xml, 'login-errors')
    for user in users:
      attrib = {'username':user}
      if users[user]['1m'] > 0: attrib['m1'] = str(users[user]['1m'])
      if users[user]['5m'] > 0: attrib['m5'] = str(users[user]['5m'])
      if users[user]['15m'] > 0: attrib['m15'] = str(users[user]['15m'])
      if users[user]['1h'] > 0: attrib['h1'] = str(users[user]['1h'])
      if users[user]['4h'] > 0: attrib['h4'] = str(users[user]['4h'])
      if users[user]['8h'] > 0: attrib['h8'] = str(users[user]['8h'])
      if users[user]['1d'] > 0: attrib['d1'] = str(users[user]['1d'])
      if users[user]['3d'] > 0: attrib['d3'] = str(users[user]['3d'])

      if users[user].has_key('dn'): attrib['dn'] = users[user]['dn']
      if users[user].has_key('badpwdcount'): attrib['badpwdcount'] = users[user]['badpwdcount']
      if users[user].has_key('badpasswordtime'): attrib['badpasswordtime'] = users[user]['badpasswordtime']
      if users[user].has_key('lastlogoff'): attrib['lastlogoff'] = users[user]['lastlogoff']
      if users[user].has_key('lastlogon'): attrib['lastlogon'] = users[user]['lastlogon']
      if users[user].has_key('logonhours'): attrib['logonhours'] = users[user]['logonhours']
      if users[user].has_key('pwdlastset'): attrib['pwdlastset'] = users[user]['pwdlastset']
      if users[user].has_key('accountexpires'): attrib['accountexpires'] = users[user]['accountexpires']
      if users[user].has_key('logoncount'): attrib['logoncount'] = users[user]['logoncount']
      if users[user].has_key('lastlogontimestamp'): attrib['lastlogontimestamp'] = users[user]['lastlogontimestamp']
      if users[user].has_key('error'): attrib['error'] = users[user]['error']
      ElementTree.SubElement(tmp, 'user', attrib=attrib)

    print ElementTree.tostring(xml, encoding=encoding, method="xml")
