#!/usr/bin/env python
"""
Python wrapper for zarafa-admin --user-count
"""
import argparse, textwrap, fnmatch, datetime, json
import xml.etree.cElementTree as ElementTree
import subprocess

# Import Brandt Common Utilities
import sys, os
sys.path.append( os.path.realpath( os.path.join( os.path.dirname(__file__), "/opt/brandt/common" ) ) )
import brandt
sys.path.pop()

args = {}
args['output'] = 'text'
args['delimiter'] = ""

version = 0.3
encoding = 'utf-8'

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
      print "Usage: " + self.__prog + " [options] [username]"
      print "Script used to find details about Zarafa licensing.\n"
      print "Options:"
      options = []
      options.append(("-h, --help",              "Show this help message and exit"))
      options.append(("-v, --version",           "Show program's version number and exit"))
      options.append(("-o, --output OUTPUT",     "Type of output {text | csv | xml | json}"))
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
  parser.add_argument('-d', '--delimiter',
          required=False,
          default=args['delimiter'],
          type=str,
          help="Character to use instead of TAB for field delimiter")
  parser.add_argument('-o', '--output',
          required=False,
          default=args['output'],
          choices=['text', 'csv', 'xml', 'json'],
          help="Display output type.")
  args.update(vars(parser.parse_args()))
  if args['delimiter']: args['delimiter'] = args['delimiter'][0]
  if not args['delimiter'] and args['output'] == "csv": args['delimiter'] = ","

def get_data():
  command = '/usr/sbin/zarafa-admin --user-count'
  p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)

  data = {'active': {'used': '0', 'available': '', 'allowed': '', 'users': '', 'rooms': '', 'equipment': ''},
          'non-active': {'used': '0', 'available': '', 'allowed': '', 'users': '', 'rooms': '', 'equipment': ''},
          'total': {'used': '0', 'available': '', 'allowed': '', 'users': '', 'rooms': '', 'equipment': ''}}

  for line in out.split('\n')[3:]:
    line = line.split()
    if line:
      line[0] = str(line[0]).strip().lower()
      if line[0] == 'active' and len(line) > 3:
        data['active'].update({'allowed':line[1], 'used':line[2], 'available':line[3]})
      elif line[0] == 'non-active' and len(line) > 3:
        data['non-active'].update({'allowed':line[1], 'used':line[2], 'available':line[3]})
      elif line[0] == 'users' and len(line) > 1:
        data['non-active'].update({'users':line[1]})
      elif line[0] == 'rooms' and len(line) > 1:
        data['non-active'].update({'rooms':line[1]})
      elif line[0] == 'equipment' and len(line) > 1:
        data['non-active'].update({'equipment':line[1]})
      elif line[0] == 'total' and len(line) > 1:
        data['total'].update({'used':line[1]})

  return data

  # if args['output'] == 'text': output +=  out + '\n'
  # if args['output'] != 'xml':
  #   if not args['delimiter']: args['delimiter'] = "\t"
  #   output += args['delimiter'].join(headers) + '\n'
  #   output += "\n".join( [ user.replace(";",args['delimiter']) for user in users ] )
  # else:
  #   data = {}
  #   xml = ElementTree.Element('users')
  #   today = datetime.datetime.today()

  #   for line in out.split('\n')[3:]:
  #     tmp = line.split('\t')
  #     if line and len(tmp) > 5:
  #       name = str(tmp[1]).strip().lower()
  #       allowed = str(tmp[-4]).strip()
  #       allowed = allowed.split()[0].lower() if allowed else "0"
  #       used = str(tmp[-3]).strip()
  #       used = used.split()[0].lower() if used else "0"
  #       available = str(tmp[-2]).strip()
  #       available = available.split()[0].lower() if available else "0"  
  #       if name in ["active", "non-active", "total"]: 
  #         data[name] = {"allowed":brandt.strXML(allowed), "used":brandt.strXML(used), "available":brandt.strXML(available)}
  #       elif data.has_key("non-active"): 
  #         data["non-active"].update({name:brandt.strXML(used)})






# Start program
if __name__ == "__main__":
  # try:
    error = ""
    xmldata = ""
    exitcode = 0

    command_line_args()  
    license = get_data()

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
    if args['output'] == 'xml': 
      xml = ElementTree.Element('zarafaadmin')
      if xmldata: xml.append(xmldata)
      xmllic = ElementTree.SubElement(xml, 'licensed')
      ElementTree.SubElement(xmllic, "active", **license['active'])
      ElementTree.SubElement(xmllic, "nonactive", **license['non-active'])
      ElementTree.SubElement(xmllic, "total", **license['total'])
      print '<?xml version="1.0" encoding="' + encoding + '"?>\n' + ElementTree.tostring(xml, encoding=encoding, method="xml")
    else:
      if error:  sys.stderr.write( str(error) + "\n" )      
      if args['output'] == 'json': 
        print json.dumps(license, indent=2, sort_keys=True)

      elif args['output'] == 'csv':
        print args['delimiter'].join(['Type','Used','Available','Allowed','Users','Rooms','Equipment'])
        print args['delimiter'].join(['active',license['active']['used'],license['active']['available'],license['active']['allowed'],
                                               license['active']['users'],license['active']['rooms'],license['active']['equipment']])
        print args['delimiter'].join(['non-active',license['non-active']['used'],license['non-active']['available'],license['non-active']['allowed'],
                                                   license['non-active']['users'],license['non-active']['rooms'],license['non-active']['equipment']])
        print args['delimiter'].join(['total',license['total']['used'],license['total']['available'],license['total']['allowed'],
                                              license['total']['users'],license['total']['rooms'],license['total']['equipment']])
        if error:  sys.stderr.write( str(error) + "\n" )      
      else:
        allowed   = max([7, len(license['active']['allowed']), len(license['non-active']['allowed'])]) + 2
        used      = max([7, len(license['active']['used']), len(license['non-active']['used']), len(license['total']['used'])]) + 2
        available = max([9, len(license['active']['available']), len(license['non-active']['available'])]) + 2

        print "Zarafa Licensing Info:"
        print "           " + "Allowed".rjust(allowed) + "Used".rjust(used) + "Available".rjust(available)
        print "-----------" + "-" * (allowed + used + available + 2)
        print "Active     " + str(license['active']['allowed']).rjust(allowed) + str(license['active']['used']).rjust(used) + str(license['active']['available']).rjust(available)
        print "Non-active " + str(license['non-active']['allowed']).rjust(allowed) + str(license['non-active']['used']).rjust(used) + str(license['non-active']['available']).rjust(available)
        print "  Users    " + str(license['users']['used']).rjust(allowed + used)
        print "  Rooms    " + str(license['rooms']['used']).rjust(allowed + used)
        print "  Equipment" + str(license['equipment']['used']).rjust(allowed + used)
        print "Total      " + str(license['total']['used']).rjust(allowed + used)
    sys.exit(exitcode)




