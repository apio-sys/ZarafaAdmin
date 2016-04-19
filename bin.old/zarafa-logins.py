#!/usr/bin/env python
"""
Python program for Zarafa
"""
import argparse, sys, datetime, base64
import xml.etree.ElementTree as ElementTree
import subprocess
#from multiprocessing import Process, Queue


args = {}
args['output'] = "text"
args['version'] = 0.3
encoding = "utf-8"

months = ('','jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec')

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
                    choices=['text', 'xml'],
                    help="Display output type.")
  args.update(vars(parser.parse_args()))

# Start program
if __name__ == "__main__":
  command_line_args()

  p = subprocess.Popen(['grep','Authentication by plugin failed for user', '/var/log/zarafa/server.log'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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
