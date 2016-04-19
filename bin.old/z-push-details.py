#!/usr/bin/env python
"""
Python program for Zarafa
"""
import argparse, re, fnmatch, datetime, os
import xml.etree.ElementTree as ElementTree
import subprocess
from multiprocessing import Process, Queue

args = {}
args['output'] = "text"
args['version'] = 0.3
args['device'] = ''
args['user'] = ''
args['list'] = False
args['cache'] = False
encoding = "utf-8"

cacheTimeout = 15 * 60

cachefile = "/opt/opw/z-push-details.cache"

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
  parser.add_argument('-d', '--device',
                    required=False,
                    default=args['device'],
                    action='store',
                    help="Device.")
  parser.add_argument('-u', '--user',
                    required=False,
                    default=args['user'],
                    action='store',
                    help="User.")
  parser.add_argument('-l', '--list',
                    required=False,
                    action='store_true',
                    help="Only show list")
  parser.add_argument('-c', '--cache',
                    required=False,
                    action='store_true',
                    help="Create Cache")
  args.update(vars(parser.parse_args()))

def CreateCache(cachefile):
  p = subprocess.Popen(['z-push-admin', '-a', 'lastsync'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)
  f = open(cachefile, 'w')
  f.write(out)
  f.close()

def ParseData(data):
  tmp = {}
  for line in data:
    line = line.lstrip("-")
    if line and ":" in line:
      tag, value = line.split(":",1)
      tag = tag.strip().lower().replace(" ","").replace("/","")
      tmp[tag] = value.strip()
  return tmp

# Start program
if __name__ == "__main__":
  command_line_args()

  if args["cache"]:
    CreateCache(cachefile)
    exit()

  mtime = datetime.datetime.now() - datetime.datetime.fromtimestamp(os.path.getmtime(cachefile))
  if cacheTimeout < mtime.seconds:
    CreateCache(cachefile)

  try:
    f = open(cachefile, 'r')
    out = str(f.read()).split('\n')
    f.close()
  except:
    raise err

  out = out[5:]
  data = []
  for line in out:
    if line:
      deviceID, username = line.split(" ",1)
      username, lastSync = username.strip().split(" ",1)
      lastSync = lastSync.strip()

      if args['device']:
        deviceID = fnmatch.filter([deviceID], args['device'])
        if deviceID: deviceID = deviceID[0]
      if args['user']:
        username = fnmatch.filter([username], args['user'])
        if username: username = username[0]

      if deviceID and username:
        try:
          lastSync = datetime.datetime( int(lastSync[0:4]), int(lastSync[5:7]), int(lastSync[8:10]), int(lastSync[11:13]), int(lastSync[14:16]) )
        except:
          lastSync = datetime.datetime(1,1,1)
        data.append( (username, deviceID, lastSync) )

  if len(data) > 1 or args["list"]:
    if args["output"] == "text":
      maxuserlen = max( [ len(l[0]) for l in data ] + [17] )
      maxdevlen =  max( [ len(l[1]) for l in data ] + [9] )
      print "Synchronized User".ljust(maxuserlen) + "  " + "Device ID".center(maxdevlen) + "   Last Sync Time"
      print "-" * (maxuserlen + maxdevlen + 23)
      for line in sorted(data):
        print str(line[0]).ljust(maxuserlen) + "  " + str(line[1]).center(maxdevlen) + "  " + str(line[2])
      exit()

    if args["output"] == "xml":
      print '<?xml version="1.0" encoding="' + encoding + '"?>'
      xml = ElementTree.Element('z-push-details')
      for line in data:
        lag = datetime.datetime.now() - line[2]
        lag = str( str(lag.days) + str(lag.seconds) ).strip("0")
        ElementTree.SubElement(xml, 'device', attrib = {"username":str(line[0]), "deviceid":str(line[1]), "sync":str(line[2]), "lag":lag})
      print ElementTree.tostring(xml, encoding=encoding, method="xml")
      exit()

  if not data: raise IOError("No data found.")

  p = subprocess.Popen(['z-push-admin', '-a', 'list', '-d', data[0][1], '-u', data[0][0]], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)
  data = out.strip().split("\n")


  for i in range(len(data))[::-1]:
    line = data[i].lstrip("-")
    if line and line[:17] == 'Attention needed:':
      error = data[i+1:]
      del data[i+1:]


  deviceData = ParseData(data)
  deviceErrors = []
  for i in range(len(error))[::-1]:
    if not error[i]:
      deviceErrors.append( ParseData(error[i:]) )
      del error[i:]
  if error:
      deviceErrors.append( ParseData(error[i:]) )


  if args["output"] == "text":
    print "Synchronized by user: ".rjust(23) + deviceData.get("synchronizedbyuser","")
    print "-" * 55
    print "Device ID: ".rjust(23) + deviceData.get("deviceid","")
    print "Device Type: ".rjust(23) + deviceData.get("devicetype","")
    print "Device Model: ".rjust(23) + deviceData.get("devicemodel","")
    print "User Agent: ".rjust(23) + deviceData.get("useragent","")
    print "Device Friendly Name: ".rjust(23) + deviceData.get("devicefriendlyname","")
    print "Device IMEI: ".rjust(23) + deviceData.get("deviceimei","")
    print "Device OS: ".rjust(23) + deviceData.get("deviceos","")
    print "ActiveSync Version: ".rjust(23) + deviceData.get("activesyncversion","")
    print "Device Operator: ".rjust(23) + deviceData.get("deviceoperator","")
    print "Device Language: ".rjust(23) + deviceData.get("deviceoslanguage","")
    print "Device Outbound SMS: ".rjust(23) + deviceData.get("deviceoutboundsms","")
    print "First Sync: ".rjust(23) + deviceData.get("firstsync","")
    print "Last Sync: ".rjust(23) + deviceData.get("lastsync","")
    print "Total Folders: ".rjust(23) + deviceData.get("totalfolders","")
    print "Synchronized Folders: ".rjust(23) + deviceData.get("synchronizedfolders","")
    print "Synchronized Data: ".rjust(23) + deviceData.get("synchronizeddata","")
    print "Status: ".rjust(23) + deviceData.get("status","")
    print "Wipe Request On: ".rjust(23) + deviceData.get("wiperequeston","")
    print "Wipe Request By: ".rjust(23) + deviceData.get("wiperequestby","")
    print "Wiped On: ".rjust(23) + deviceData.get("wipedon","")
    print "Attention Needed: ".rjust(23) + deviceData.get("attentionneeded","")
    for error in deviceErrors:
      print "Broken object: ".rjust(25) + error.get("brokenobject","")
      print "Information: ".rjust(25) + error.get("information","")
      print "Reason: ".rjust(25) + error.get("reason","")
      print "Item/Parent id: ".rjust(25) + error.get("itemparentid","")
      print
    exit()

  if args["output"] == "xml":
    print '<?xml version="1.0" encoding="' + encoding + '"?>'
    xml = ElementTree.Element('z-push-details')
    device = ElementTree.SubElement(xml, 'device', attrib = deviceData)
    for error in deviceErrors:
      ElementTree.SubElement(device, 'error', attrib = error)

    print ElementTree.tostring(xml, encoding=encoding, method="xml")
    exit()
