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
args['command'] = 'user'
args['object'] = ''
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
										choices=['text','csv', 'xml'],
										help="Display output type.")
	parser.add_argument('-c', '--command',
										required=False,
										default=args['command'],
										choices=['user','group', 'count','orphans'],
										help="Command.")
	parser.add_argument('object',
										nargs='?',
										default= args['object'],
										action='store',
										help="Object to retrieve details about.")  
	args.update(vars(parser.parse_args()))
	args['command'] = str(args['command']).lower()
	args['object'] = str(args['object']).lower()

def users()
	global args

	p = subprocess.Popen(['z-push-admin', '-a', 'list'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	out, err = p.communicate()
	if err: raise IOError(err)
	out = re.sub( r" +", " ", out)






# Start program
if __name__ == "__main__":
	command_line_args()

	print args

	# p = subprocess.Popen(['z-push-admin', '-a', 'list'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	# out, err = p.communicate()
	# if err: raise IOError(err)
	# out = re.sub( r" +", " ", out)
