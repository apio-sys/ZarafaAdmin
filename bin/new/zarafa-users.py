#!/usr/bin/env python
"""
Python wrapper for zarafa-stats --users
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
args['user'] = ''
args['delimiter'] = "\t"

version = 0.3
encoding = 'utf-8'


headers = ['company','username','fullname','emailaddress','active','admin','UNK0x67C1001E','size','quotawarn','quotasoft','quotahard','UNK0x67200040','UNK0x6760000B','logon','logoff']
#headers['session'] = ['UNK0x67420014','UNK0x674D0014','ip','UNK0x67440003','UNK0x67450003','UNK0x6746000B','username','UNK0x6747101E','UNK0x6749101E','UNK0x674A0005','UNK0x674B0005','UNK0x674C0005','UNK0x674E0003','version','program','UNK0x67510003','UNK0x67480003','UNK0x6753001E','pipe']
#headers['system'] = ['parameter','description','value']
ldapmapping = (("pr_ec_enabled_features","0x67b3101e"),("pr_ec_disabled_features","0x67b4101e"),("pr_ec_archive_servers","0x67c4101e"),("pr_ec_archive_couplings","0x67c5101e"),("pr_ec_exchange_dn","0x678001e"),("pr_business_telephone_number","0x3a08001e"),("pr_business2_telephone_number","0x3a1b101e"),("pr_business_fax_number","0x3a24001e"),("pr_mobile_telephone_number","0x3a1c001e"),("pr_home_telephone_number","0x3a09001e"),("pr_home2_telephone_number","0x3a2f101e"),("pr_primary_fax_number","0x3a23001e"),("pr_pager_telephone_number","0x3a21001e"),("pr_comment","0x3004001e"),("pr_department_name","0x3a18001e"),("pr_office_location","0x3a19001e"),("pr_given_name","0x3a06001e"),("pr_surname","0x3a11001e"),("pr_childrens_names","0x3a58101e"),("pr_business_ddress_city","0x3a27001e"),("pr_title","0x3a17001e"),("pr_user_certificate","0x3a220102"),("pr_initials","0x3a0a001e"),("pr_language","0x3a0c001e"),("pr_organizational_id_number","0x3a10001e"),("pr_postal_address","0x3a15001e"),("pr_company_name","0x3a16001e"),("pr_country","0x3a26001e"),("pr_state_or_province","0x3a28001e"),("pr_street_address","0x3a29001e"),("pr_postal_code","0x3a2a001e"),("pr_post_office_box","0x3a2b001e"),("pr_assistant","0x3a30001e"),("pr_ems_ab_www_home_page","0x8175101e"),("pr_business_home_page","0x3a51001e"),("pr_ems_ab_is_member_of_dl","0x80081102"),("pr_ems_ab_reports","0x800e1102"),("pr_manager_name","0x8005001e"),("pr_ems_ab_owner","0x800c001e"))


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
      print "Script used to find details about Zarafa users.\n"
      print "Options:"
      options = []
      options.append(("-h, --help",              "Show this help message and exit"))
      options.append(("-v, --version",           "Show program's version number and exit"))
      options.append(("-o, --output OUTPUT",     "Type of output {text | csv | xml}"))
      options.append(("-c, --cache MINUTES",     "Cache time. (in minutes)"))
      options.append(("-d, --delimiter DELIM",   "Character to use instead of TAB for field delimiter"))
      options.append(("username",     "Filter to apply to usernames."))
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
  parser.add_argument('user',
          nargs='?',
          default= args['user'],
          action='store',
          help="User to retrieve details about.")
  args.update(vars(parser.parse_args()))
  args['delimiter'] = args['delimiter'][0]
  if args['output'] == "csv": args['delimiter'] = ","


def get_data():
  global args
  command = '/usr/bin/zarafa-stats --users --dump'
  cachefile = '/tmp/zarafa-users.cache'    

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

    out = out.strip().split('\n')[1:]
    for c in reversed(range(len(out))):
      if not out[c]:
        out.pop(c)
      else:
        tmp = out[c].split(";")
        if tmp[headers.index("username")] == tmp[headers.index("fullname")] == "SYSTEM": out.pop(c)

    f = open(cachefile, 'w')
    f.write("\n".join(out))
    f.close()
  else:
    f = open(cachefile, 'r')
    out = f.read().split('\n')
    f.close()

  # Apply username filter    
  users = {}
  for line in out:
    if line:
      tmp = line.split(";")
      if args['user']:
        if not fnmatch.fnmatch(tmp[headers.index("username")].lower(), args['user']): continue
      users[tmp[headers.index("username")].lower()] = line
  out = []
  for user in sorted(users.keys()):
    out.append(users[user])

  return out

def zarafa_users(users):
  global args

  if args['output'] != 'xml':
    print args['delimiter'].join(headers)
    print "\n".join( [ user.replace(";",args['delimiter']) for user in users ] )
    sys.exit(0)

  xml = ElementTree.Element('users')
  for user in users:
    tmp = user.split(';')
    xmluser = ElementTree.SubElement(xml, "user")
    for i in range(len(tmp)):
      try:
        if tmp[i] and headers[i] in ['logon','logoff']:
          today = datetime.datetime.today()
          date = datetime.datetime.strptime(tmp[i].decode('unicode_escape'),'%a %b %d %H:%M:%S %Y')
          child = ElementTree.SubElement(xmluser, headers[i], lag=str((today - date).days))
        else:
          child = ElementTree.SubElement(xmluser, headers[i])
        child.text = tmp[i].decode('unicode_escape')
      except:
        pass
  return xml

def zarafa_user(username):
  global args, ldapmapping
  command = '/usr/sbin/zarafa-admin --type user --details ' + str(username)

  p = subprocess.Popen(command.split(" "), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  out, err = p.communicate()
  if err: raise IOError(err)

  data = str(out).split("\n")
  groups = []
  quotas = []
  props = []
  for i in reversed(range(len(data))):
    if not data[i]: 
      del data[i]
    else:
      if data[i][:8] == "Groups (":
        groups = data[i:]
        del data[i:]
      elif data[i] == "Current user store quota settings:":
        quotas = data[i:]
        del data[i:]
      elif data[i] == "Mapped properties:":
        props = data[i:]
        del data[i:]

  del groups[0]
  groups = [ str(x).lower().strip() for x in groups ]
  groups.remove("everyone")

  props = [ (str(str(x).split('\t')[1]).lower(), ''.join(str(x).split('\t')[2:])) for x in props[1:] ]
  props = { x[0]:x[1] for x in props }

  data += quotas[1:]
  data = [ str(x).replace(":",":\t",1) for x in data ]
  data = [ ( str(str(x).split('\t')[0]).lower().replace(" ","").replace(":","").replace("-",""), ''.join(str(x).split('\t')[1:]) ) for x in data ]
  data = { x[0]:x[1] for x in data }
  data.update(props)

  data["username"] = data.get("username","").lower()
  data["emailaddress"] = data.get("emailaddress","").lower()
  if data.has_key("warninglevel"): data["warninglevel"] = data.get("warninglevel","").split(" ")[0]
  if data.has_key("softlevel"): data["softlevel"] = data.get("softlevel","").split(" ")[0]
  if data.has_key("hardlevel"): data["hardlevel"] = data.get("hardlevel","").split(" ")[0]
  if data.has_key("currentstoresize"): data["currentstoresize"] = data.get("currentstoresize","").split(" ")[0]

  for good,bad in ldapmapping:
    if data.has_key(bad):
      data[good] = data[bad]
      del data[bad]

  xml = ElementTree.Element('users')
  if args['output'] == "text":
    maxlen = max([ len(x) + 4 for x in data.keys() ] + [25])
    print "Username:".ljust(maxlen), data.get("username","")
    print "Fullname:".ljust(maxlen), data.get("fullname","")
    print "Emailaddress:".ljust(maxlen), data.get("emailaddress","")
    print "Active:".ljust(maxlen), data.get("active","")
    print "Administrator:".ljust(maxlen), data.get("administrator","")
    print "Address book:".ljust(maxlen), data.get("addressbook","")
    print "Auto-accept meeting req:".ljust(maxlen), data.get("autoacceptmeetingreq","")
    print "Last logon:".ljust(maxlen), data.get("lastlogon","")
    print "Last logoff:".ljust(maxlen), data.get("lastlogoff","")
    print "Mapped properties:"
    print " PR_GIVEN_NAME:".ljust(maxlen), data.get("pr_given_name","")
    print " PR_INITIALS:".ljust(maxlen), data.get("pr_initials","")
    print " PR_SURNAME:".ljust(maxlen), data.get("pr_surname","")
    print " PR_COMPANY_NAME:".ljust(maxlen), data.get("pr_company_name","")
    print " PR_TITLE:".ljust(maxlen), data.get("pr_title","")
    print " PR_DEPARTMENT_NAME:".ljust(maxlen), data.get("pr_department_name","")
    print " PR_OFFICE_LOCATION:".ljust(maxlen), data.get("pr_office_location","")
    print " PR_BUSINESS_TELEPHONE_NUMBER:".ljust(maxlen), data.get("pr_business_telephone_number","")
    print " PR_HOME_TELEPHONE_NUMBER:".ljust(maxlen), data.get("pr_home_telephone_number","")      
    print " PR_PAGER_TELEPHONE_NUMBER:".ljust(maxlen), data.get("pr_pager_telephone_number","")
    print " PR_PRIMARY_FAX_NUMBER:".ljust(maxlen), data.get("pr_primary_fax_number","")
    print " PR_BUSINESS_FAX_NUMBER:".ljust(maxlen), data.get("pr_business_fax_number","")
    print " PR_COUNTRY:".ljust(maxlen), data.get("pr_country","")
    print " PR_STATE_OR_PROVINCE:".ljust(maxlen), data.get("pr_state_or_province","")
    print " PR_EMS_AB_IS_MEMBER_OF_DL:".ljust(maxlen), data.get("pr_ems_ab_is_member_of_dl","")
    print " PR_EC_ENABLED_FEATURES:".ljust(maxlen), data.get("pr_ec_enabled_features","")
    print " PR_EC_DISABLED_FEATURES:".ljust(maxlen), data.get("pr_ec_disabled_features","")
    if data.has_key("pr_assistant"): print " PR_ASSISTANT:".ljust(maxlen), data.get("pr_assistant","")
    if data.has_key("pr_business2_telephone_number"): print " PR_BUSINESS2_TELEPHONE_NUMBER:".ljust(maxlen), data.get("pr_business2_telephone_number","")
    if data.has_key("pr_business_address_city"): print " PR_BUSINESS_ADDRESS_CITY:".ljust(maxlen), data.get("pr_business_address_city","")
    if data.has_key("pr_business_home_page"): print " PR_BUSINESS_HOME_PAGE:".ljust(maxlen), data.get("pr_business_home_page","")
    if data.has_key("pr_childrens_names"): print " PR_CHILDRENS_NAMES:".ljust(maxlen), data.get("pr_childrens_names","")
    if data.has_key("pr_comment"): print " PR_COMMENT:".ljust(maxlen), data.get("pr_comment","")
    if data.has_key("pr_company_name"): print " PR_COMPANY_NAME:".ljust(maxlen), data.get("pr_company_name","")
    if data.has_key("pr_ec_exchange_dn"): print " PR_EC_EXCHANGE_DN:".ljust(maxlen), data.get("pr_ec_exchange_dn","")
    if data.has_key("pr_ems_ab_owner"): print " PR_EMS_AB_OWNER:".ljust(maxlen), data.get("pr_ems_ab_owner","")
    if data.has_key("pr_ems_ab_reports"): print " PR_EMS_AB_REPORTS:".ljust(maxlen), data.get("pr_ems_ab_reports","")
    if data.has_key("pr_ems_ab_www_home_page"): print " PR_EMS_AB_WWW_HOME_PAGE:".ljust(maxlen), data.get("pr_ems_ab_www_home_page","")
    if data.has_key("pr_home2_telephone_number"): print " PR_HOME2_TELEPHONE_NUMBER:".ljust(maxlen), data.get("pr_home2_telephone_number","")
    if data.has_key("pr_language"): print " PR_LANGUAGE:".ljust(maxlen), data.get("pr_language","")
    if data.has_key("pr_manager_name"): print " PR_MANAGER_NAME:".ljust(maxlen), data.get("pr_manager_name","")
    if data.has_key("pr_mobile_telephone_number"): print " PR_MOBILE_TELEPHONE_NUMBER:".ljust(maxlen), data.get("pr_mobile_telephone_number","")
    if data.has_key("pr_organizational_id_number"): print " PR_ORGANIZATIONAL_ID_NUMBER:".ljust(maxlen), data.get("pr_organizational_id_number","")
    if data.has_key("pr_post_office_box"): print " PR_POST_OFFICE_BOX:".ljust(maxlen), data.get("pr_post_office_box","")
    if data.has_key("pr_postal_address"): print " PR_POSTAL_ADDRESS:".ljust(maxlen), data.get("pr_postal_address","")
    if data.has_key("pr_postal_code"): print " PR_POSTAL_CODE:".ljust(maxlen), data.get("pr_postal_code","")
    if data.has_key("pr_street_address"): print " PR_STREET_ADDRESS:".ljust(maxlen), data.get("pr_street_address","")
    if data.has_key("pr_user_certificate"): print " PR_USER_CERTIFICATE:".ljust(maxlen), data.get("pr_user_certificate","")
    print "Current user store quota settings:"
    print " Quota overrides:".ljust(maxlen), data.get("quotaoverrides","")
    print " Warning level (MB):".ljust(maxlen), data.get("warninglevel","")
    print " Soft level (MB):".ljust(maxlen), data.get("softlevel","")
    print " Hard level (MB):".ljust(maxlen), data.get("hardlevel","")
    print "Current store size (MB):".ljust(maxlen), data.get("currentstoresize","")
    print "Groups (" + str(len(groups)) + "):"
    print '-' * (maxlen)
    print '\n'.join([ " " + str(x) for x in groups ])
    sys.exit(0)

  elif args['output'] == "csv":
    tmp = data.get("username","")
    tmp += ',' + data.get("fullname","")
    tmp += ',' + data.get("emailaddress","")
    tmp += ',' + data.get("active","")
    tmp += ',' + data.get("administrator","")
    tmp += ',' + data.get("addressbook","")
    tmp += ',' + data.get("autoacceptmeetingreq","")
    tmp += ',' + data.get("lastlogon","")
    tmp += ',' + data.get("lastlogoff","")
    tmp += ',' + data.get("quotaoverrides","")
    tmp += ',' + data.get("warninglevel","")
    tmp += ',' + data.get("softlevel","")
    tmp += ',' + data.get("hardlevel","")
    tmp += ',' + data.get("currentstoresize","")
    tmp += ',' + ';'.join(groups)
    tmp += ',' + data.get("pr_given_name","")
    tmp += ',' + data.get("pr_initials","")
    tmp += ',' + data.get("pr_surname","")
    tmp += ',' + data.get("pr_company_name","")
    tmp += ',' + data.get("pr_title","")
    tmp += ',' + data.get("pr_department_name","")
    tmp += ',' + data.get("pr_business_telephone_number","")
    tmp += ',' + data.get("pr_home_telephone_number","")
    tmp += ',' + data.get("pr_pager_telephone_number","")
    tmp += ',' + data.get("pr_primary_fax_number","")
    tmp += ',' + data.get("pr_business_fax_number","")
    tmp += ',' + data.get("pr_country","")
    tmp += ',' + data.get("pr_state_or_province","")
    tmp += ',' + data.get("pr_ems_ab_is_member_of_dl","")
    tmp += ',' + data.get("pr_ec_enabled_features","")
    tmp += ',' + data.get("pr_ec_disabled_features","")
    tmp += ',' + data.get("pr_assistant","")
    tmp += ',' + data.get("pr_business2_telephone_number","")
    tmp += ',' + data.get("pr_business_address_city","")
    tmp += ',' + data.get("pr_business_home_page","")
    tmp += ',' + data.get("pr_childrens_names","")
    tmp += ',' + data.get("pr_comment","")
    tmp += ',' + data.get("pr_company_name","")
    tmp += ',' + data.get("pr_ec_exchange_dn","")
    tmp += ',' + data.get("pr_ems_ab_owner","")
    tmp += ',' + data.get("pr_ems_ab_reports","")
    tmp += ',' + data.get("pr_ems_ab_www_home_page","")
    tmp += ',' + data.get("pr_home2_telephone_number","")
    tmp += ',' + data.get("pr_language","")
    tmp += ',' + data.get("pr_manager_name","")
    tmp += ',' + data.get("pr_mobile_telephone_number","")
    tmp += ',' + data.get("pr_office_location","")
    tmp += ',' + data.get("pr_organizational_id_number","")
    tmp += ',' + data.get("pr_post_office_box","")
    tmp += ',' + data.get("pr_postal_address","")
    tmp += ',' + data.get("pr_postal_code","")
    tmp += ',' + data.get("pr_street_address","")
    tmp += ',' + data.get("pr_user_certificate","")
    print tmp
    sys.exit(0)

  else:
    xmluser = ElementTree.SubElement(xml, 'user', attrib=data)
    memberof = ElementTree.SubElement(xmluser, 'groups')
    for group in groups:
        ElementTree.SubElement(memberof, 'group', attrib={"groupname":group})
  return xml





# Start program
if __name__ == "__main__":
    command_line_args()

  # exitcode = 0
  # try:
    users = get_data()
    if len(users) == 1:
      xmldata = zarafa_user(users[0].split(";")[headers.index("username")])
    else:
      xmldata = zarafa_users(users)

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