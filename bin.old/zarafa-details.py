#!/usr/bin/env python
"""
Python program for Zarafa
"""
import argparse, re, fnmatch
import xml.etree.ElementTree as ElementTree
import subprocess
from multiprocessing import Process, Queue

args = {}
args['users'] = False
args['groups'] = False
args['output'] = "text"
args['object'] = 'brandtb'
args['version'] = 0.3
args['object'] = ''
encoding = "utf-8"

alluserfields={ "current store size:":"currentsize",
                       " hard level:":"hardquota",
                       " soft level:":"softquota",
                       " warning level:":"warningquota",
                       " quota overrides:":"quotaoveride",
                       "last logoff:":"logoff",
                       "last logon:":"logon",
                       "auto-accept meeting req:":"autoaccept",
                       "address book:":"visible",
                       "administrator:":"admin",
                       "active:":"active",
                       "emailaddress:":"emailaddress",
                       "homeserver":"homeserver",
                       "fullname:":"fullname",
                       "username:":"username"}  
quotafields={"current store size:":"currentsize",
                     " hard level:":"hardquota",
                     " soft level:":"softquota",
                     " warning level:":"warningquota",
                     " quota overrides:":"quotaoveride",
                     "emailaddress:":"emailaddress",
                     "fullname:":"fullname",
                     "username:":"username"}  

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
  parser.add_argument('-u', '--users',
                    required=False,
                    default=args['users'],
                    action='store_true',
                    help="Display users only.")
  parser.add_argument('-g', '--groups',
                    required=False,
                    default=args['groups'],
                    action='store_true',
                    help="Display groups only.")
  parser.add_argument('-o', '--output',
                    required=False,
                    default=args['output'],
                    choices=['text', 'xml'],
                    help="Display output type.")
  parser.add_argument('object',
                    nargs='?',
                    default= args['object'],
                    action='store',
                    help="Object to retrieve details about.")  
  args.update(vars(parser.parse_args()))
  if not( args['users'] or args['groups'] ):
    args['users'] = True
    args['groups'] = True
  if not args['object']:
    args['object'] = '*'

class zarafaUser(object):
  __userfields = { "fullname": "fullname",
                   # "username": "username",  
                   "homeserver": "homeserver",
                   "emailaddress": "emailaddress",
                   "active": "active",
                   "administrator": "admin",
                   "address book": "visible",
                   "auto-accept meeting req": "autoaccept",
                   "last logon": "logon",
                   "last logoff": "logoff",
                   "quota overrides": "quotaoveride",
                   "warning level": "warningquota",
                   "soft level": "softquota",
                   "hard level": "hardquota",
                   "current store size": "currentsize"}
  __userfieldsorder = [ "username", "fullname", "homeserver", "emailaddress", "active", "admin", "visible", "autoaccept", "logon", "logoff" ]
  __userquotaorder  = [ "quotaoveride", "warningquota", "softquota", "hardquota",  "currentsize" ]
  __mappedpropfields = { "pr_assistant": "assistant",
                         "pr_business2_telephone_number": "telephone2",
                         "pr_business_address_city": "businesscity",
                         "pr_business_fax_number": "businessfax",
                         "pr_business_home_page": "businesshomepage",
                         "pr_business_telephone_number": "telephone",
                         "pr_childrens_names": "childrensnames",
                         "pr_comment": "comment",
                         "pr_company_name": "company",
                         "pr_country": "country",
                         "pr_department_name": "department",
                         "pr_ec_archive_couplings": "archivecouplings",
                         "pr_ec_archive_servers": "archiveservers",
                         "pr_ec_disabled_features": "disabledfeatures",
                         "pr_ec_enabled_features": "enabledfeatures",
                         "pr_ec_exchange_dn": "exchangedn",
                         "pr_ems_ab_is_member_of_dl": "memberof",
                         "pr_ems_ab_owner": "managedby",
                         "pr_ems_ab_reports": "directreports",
                         "pr_ems_ab_www_home_page": "url",
                         "pr_given_name": "givenname",
                         "pr_home2_telephone_number": "homephone2",
                         "pr_home_telephone_number": "homephone",
                         "pr_initials": "initials",
                         "pr_language": "language",
                         "pr_locality": "locality",
                         "pr_manager_name": "manager",
                         "pr_mobile_telephone_number": "mobile",
                         "pr_office_location": "location",
                         "pr_organizational_id_number": "employeenumber",
                         "pr_pager_telephone_number": "pager",
                         "pr_post_office_box": "postofficebox",
                         "pr_postal_address": "postaladdress",
                         "pr_postal_code": "postalcode",
                         "pr_primary_fax_number": "fax",
                         "pr_state_or_province": "state",
                         "pr_street_address": "street",
                         "pr_surname": "surname",
                         "pr_title": "title",
                         "pr_user_certificate": "usercertificate",
                         "pr_user_certificate": "usercertificate",                         
                         "0x3004001e": "comment",
                         "0x3a06001e": "givenname",
                         "0x3a08001e": "telephone",
                         "0x3a09001e": "homephone",
                         "0x3a0a001e": "initials",
                         "0x3a0c001e": "language",
                         "0x3a10001e": "employeenumber",
                         "0x3a11001e": "surname",
                         "0x3a15001e": "postaladdress",
                         "0x3a16001e": "company",
                         "0x3a17001e": "title",
                         "0x3a18001e": "department",
                         "0x3a19001e": "location",
                         "0x3a1b101e": "telephone2",
                         "0x3a1c001e": "mobile",
                         "0x3a21001e": "pager",
                         "0x3a220102": "usercertificate",
                         "0x3a23001e": "fax",
                         "0x3a24001e": "businessfax",
                         "0x3a26001e": "country",
                         "0x3a27001e": "businesscity",
                         "0x3a28001e": "state",
                         "0x3a29001e": "street",
                         "0x3a2a001e": "postalcode",
                         "0x3a2b001e": "postofficebox",
                         "0x3a2f101e": "homephone2",
                         "0x3a30001e": "assistant",
                         "0x3a51001e": "businesshomepage",
                         "0x3a58101e": "childrensnames",
                         "0x6788001e": "exchangedn",
                         "0x67b3101e": "enabledfeatures",
                         "0x67b4101e": "disabledfeatures",
                         "0x67c4101e": "archiveservers",
                         "0x67c5101e": "archivecouplings",
                         "0x8005001e": "manager",
                         "0x80081102": "memberof",
                         "0x800c001e": "managedby",
                         "0x800e1102": "directreports",
                         "0x8175101e": "url"}
  __mappedproporder = [ 'givenname', 'initials' , 'surname', 'telephone', 'telephone2', 'mobile', 'pager', 'businessfax', 'fax', 'homephone', 'homephone2', 'locality', 'location', 'employeenumber',
                        'company', 'title', 'department', 'businesscity', 'country', 'exchangedn', 'postaladdress', 'postalcode', 'postofficebox', 'state', 'street',
                        'managedby', 'manager', 'directreports', 'assistant', 'memberof', 'language', 'url', 'businesshomepage', 'usercertificate', 'archivecouplings', 'archiveservers',
                        'childrensnames', 'enabledfeatures', 'disabledfeatures', 'comment']

  def __init__(self, username, fullname = "", homeserver = ""):
    self.__data = {}
    self.__data["username"] = str(username).lower()
    self.__data["fullname"] = fullname
    self.__data["homeserver"] = homeserver
    p = subprocess.Popen(['zarafa-admin', '--type', 'user', '--details', self.__data["username"]], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)

    lines = [ line.replace('\t',' ').strip() for line in str(out).split('\n') ]

    for item in range(len(lines))[::-1]:
      # See if there is a Groups field
      if lines[item][:8].lower() == "groups (" and lines[item][-2:] == "):":
        tmp = lines[item:]
        self.__data["groups"] = []
        for line in lines[item:]:
          if line[:8].lower() == "groups (" and line[-2:] == "):": continue
          if len(line) < 1: continue    
          if line == 'Everyone': continue
          self.__data["groups"].append(line)
        lines = lines[:item]
        continue

      if lines[item].lower() == "mapped properties:":
        for line in lines[item:]:
          tmp = line.split(" ",1)
          tmp[0] = tmp[0].lower()
          for field in self.__mappedpropfields.keys():
            if tmp[0] == field:
              if len(tmp) > 1:
                self.__data[self.__mappedpropfields[field]] = tmp[1].strip()
              else:
                self.__data[self.__mappedpropfields[field]] = ""
              break
        lines = lines[:item]
        continue

      if ":" in lines[item]:
        tmp = lines[item].split(":",1)
        tmp[0] = tmp[0].lower()
        for field in self.__userfields.keys():
          if tmp[0] == field:
            if len(tmp) > 1:
              self.__data[self.__userfields[field]] = tmp[1].strip()
            else:
              self.__data[self.__userfields[field]] = ""          
            del lines[item]
            break

  data    = property(fget = lambda self: self.__data)

  def __getattr__(self, attribute):
    attr = str(attribute).lower()
    if self.__data.has_key(attr): return self.__data[attr]
    if attr in self.__userfields.values(): return ""
    if attr in self.__mappedpropfields.values(): return ""
    raise AttributeError("'zarafaUser' object has no attribute '" + str(attribute) + "'")

  def __contains__(self, key):
    return self.__data.__contains__(self, str(key).lower())

  def __getitem__(self, attribute, default = ""):
    attr = str(attribute).lower()
    if self.__data.has_key(attr): return self.__data[attr]
    if attr in self.__userfields.values(): return default
    if attr in self.__mappedpropfields.values(): return default
    raise KeyError(str(attribute))

  def __iter__(self):
    return iter(self.__data)

  def __len__(self):
    return len(self.__data)

  def has_key(self, key):
    return self.__data.has_key(str(key).lower())

  def keys(self):
    return self.__data.keys()

  def copy(self):
    return self.__data.copy()

  def items(self):
    return self.__data.items()

  def values(self):
    return self.__data.values()

  def iteritems(self):
    return self.__data.iteritems()

  def iterkeys(self):
    return self.__data.iterkeys()

  def itervalues(self):
    return self.__data.itervalues()

  def get(self, key, default = ""):
    return self.__getitem__(key, default)

  def __str__(self):
    l = 25
    for field, value in self.__mappedpropfields.items():
      if self.has_key(value) and len(field) > l: l = len(field)

    l += 3
    text = "-" * min([80,l*2]) + "\n"
    text += "Username:".ljust(l) + self["username"] + "\n"
    text += "Fullname:".ljust(l) + self["fullname"] + "\n"
    text += "Home Server:".ljust(l) + self["homeserver"] + "\n"
    text += "Email Address:".ljust(l) + self["emailaddress"] + "\n"
    text += "Active:".ljust(l) + self["active"] + "\n"
    text += "Administrator:".ljust(l) + self["admin"] + "\n"
    text += "Address Book:".ljust(l) + self["visible"] + "\n"
    text += "Auto-accept Meeting Req:".ljust(l) + self["autoaccept"] + "\n"
    text += "Last Logon:".ljust(l) + self["logon"] + "\n"
    text += "Last Logoff:".ljust(l) + self["logoff"] + "\n"
    text += "Other Mapped Properties:\n"
    for field in self.__mappedproporder:
      if self.has_key(field):
        for key, value in self.__mappedpropfields.items():
          if field == value and key[:3] == "pr_":
            key = key[3:]
            if key[:3] == "ec_": key = key[3:]
            if key[:4] == "ems_": key = key[4:]
            key = key.replace("_"," ").title()
            text += "  " + key.ljust(l-2) + self[value] + "\n"
            break

    text += "current User Store Quota Settings:\n"
    text += "  Quota Overrides:".ljust(l) + self["quotaoveride"] + "\n"
    text += "  Warning Level:".ljust(l) + self["warningquota"] + "\n"
    text += "  Soft Level:".ljust(l) + self["softquota"] + "\n"
    text += "  Hard Level:".ljust(l) + self["hardquota"] + "\n"
    text += "  Current Store Size:".ljust(l) + self["currentsize"] + "\n"
    if self.has_key("groups") and len(self["groups"]) > 0:
      text += "Groups (" + str(len(self["groups"])) + "):\n"
      for group in sorted(self["groups"], key=lambda s: s.lower()):
        text += "  " + str(group) + "\n"
    return text

  def xml(self):
    user = ElementTree.Element('user')
    for field in self.__userfieldsorder:
      if self.has_key(field) and self[field]:
        user.attrib[str(field)] = self[field]
    quota = ElementTree.SubElement(user, 'quota')
    for field in self.__userquotaorder:
      if self.has_key(field) and self[field]:
        quota.attrib[str(field)] = self[field]
    if self.has_key("groups"):
      for group in self["groups"]:
        ElementTree.SubElement(user, 'group', attrib={"groupname":str(group)} )
    return user

class zarafaUsers(object):
  def __init__(self, filter="*"):
    p = subprocess.Popen(['zarafa-admin', '-l'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)
    data = str(out).split("\n")
    tmp= {}
    self.__users = {}
    for item in range(len(data))[::-1]:
      line = data[item]
      if len(line) < 1: continue    
      if line[0] != '\t': continue    
      line = re.sub( r"\t+", "\t", line)
      line = re.sub( r"^\t", "", line).split("\t")
      if len(line) < 2: continue
      if len(line) > 3 and line[0] == "SYSTEM" and line[1] == "SYSTEM" and line[2] == "Zarafa": break
      if len(line) < 3: line += ['','','']

      # Save the HomeServer info (This is not listed int he details page.)
      tmp[line[0].lower()] = { "username":line[0], "fullname":line[1], "homeserver":line[2] }

    for user in fnmatch.filter(sorted(tmp.keys()), filter):
      temp = zarafaUser(username = tmp[user]["username"], fullname = tmp[user]["fullname"], homeserver = tmp[user]["homeserver"] )
      self.__users[user] = temp

  users   = property(fget = lambda self: self.__users)

  def __contains__(self, username):
    return self.__users.__contains__(self, str(username).lower())

  def __getitem__(self, username):
    user = str(username).lower()
    if self.__users.has_key(user): return self.__users[user]
    raise KeyError(str(username))

  def __iter__(self):
    return self.__users.iteritems()

  def __len__(self):
    return len(self.__users)

  def has_key(self, username):
    return self.__users.has_key(str(username).lower())

  def keys(self):
    return self.__users.keys()

  def copy(self):
    return self.__users.copy()

  def items(self):
    return self.__users.items()

  def values(self):
    return self.__users.values()

  def iteritems(self):
    return self.__users.iteritems()

  def iterkeys(self):
    return self.__users.iterkeys()

  def itervalues(self):
    return self.__users.itervalues()

  def get(self, username):
    return self.__getitem__(username)



class zarafaGroup(object):
  __groupfields = { "groupname": "groupname",
                             "fullname": "fullname",
                             "emailaddress": "emailaddress",
                             "address book": "visible" }
  __groupfieldsorder = [ "groupname", "fullname", "emailaddress", "visible" ]

  def __init__(self, groupname, fullname = "", homeserver = ""):
    self.__data = {}
    self.__data["groupname"] = str(groupname).lower()
    p = subprocess.Popen(['zarafa-admin', '--type', 'group', '--details', self.__data["groupname"]], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)

    lines = [ line.strip() for line in str(out).split('\n') ]

    for item in range(len(lines))[::-1]:
      # See if there is a Users field
      if lines[item][:7].lower() == "users (" and lines[item][-2:] == "):":
        self.__data["users"] = []
        for line in lines[item:]:
          if line[:7].lower() == "users (" and line[-2:] == "):": continue
          if line[:10] == line[-10:]  == '-' * 10: continue
          if len(line) < 1: continue    
          tmp = []
          for field in line.split("\t"):
            if field: tmp.append(field)
          tmp += ["","", ""]
          username, fullname, homeserver = tmp[0], tmp[1], tmp[2]
          if username == "Username" and fullname == "Fullname" and homeserver == "Homeserver": continue
          self.__data["users"].append({"username":username, "fullname":fullname, "homeserver":homeserver })
        lines = lines[:item]
        continue

      if ":" in lines[item]:
        tmp = lines[item].split(":",1)
        tmp[0] = tmp[0].lower()
        for field in self.__groupfields.keys():
          if tmp[0] == field:
            if len(tmp) > 1:
              self.__data[self.__groupfields[field]] = tmp[1].strip()
            else:
              self.__data[self.__groupfields[field]] = ""          
            del lines[item]
            break

  data    = property(fget = lambda self: self.__data)

  def __getattr__(self, attribute):
    attr = str(attribute).lower()
    if self.__data.has_key(attr): return self.__data[attr]
    if attr in self.__userfields.values(): return ""
    raise AttributeError("'zarafaGroup' object has no attribute '" + str(attribute) + "'")

  def __contains__(self, key):
    return self.__data.__contains__(self, str(key).lower())

  def __getitem__(self, attribute, default = ""):
    attr = str(attribute).lower()
    if self.__data.has_key(attr): return self.__data[attr]
    if attr in self.__groupfields.values(): return default
    raise KeyError(str(attribute))

  def __iter__(self):
    return iter(self.__data)

  def __len__(self):
    return len(self.__data)

  def has_key(self, key):
    return self.__data.has_key(str(key).lower())

  def keys(self):
    return self.__data.keys()

  def copy(self):
    return self.__data.copy()

  def items(self):
    return self.__data.items()

  def values(self):
    return self.__data.values()

  def iteritems(self):
    return self.__data.iteritems()

  def iterkeys(self):
    return self.__data.iterkeys()

  def itervalues(self):
    return self.__data.itervalues()

  def get(self, key, default = ""):
    return self.__getitem__(key, default)

  def __str__(self):
    l = 17
    text = "-" * min([80,l*3]) + "\n"
    text += "Groupname:".ljust(l) + self["groupname"] + "\n"
    text += "Fullname:".ljust(l) + self["fullname"] + "\n"
    text += "Email Address:".ljust(l) + self["emailaddress"] + "\n"
    text += "Address Book:".ljust(l) + self["visible"] + "\n"

    if self.has_key("users") and len(self["users"]) > 0:
      l = {"username":8, "fullname":8, "homeserver":10}
      for user in self["users"]:
        l = {"username":max(len(user["username"]),l["username"]), "fullname":max(len(user["fullname"]),l["fullname"]), "homeserver":max(len(user["homeserver"]),l["homeserver"])} 
      l = {"username":l["username"]+3, "fullname":l["fullname"]+3, "homeserver":l["homeserver"]+3}

      text += "Users (" + str(len(self["users"])) + "):\n"
      text += "  " + "Username".ljust(l["username"]) + "Fullname".ljust(l["fullname"]) + "Homeserver".ljust(l["homeserver"]) + "\n"
      text += "  " + "-" * (l["username"] + l["fullname"] + l["homeserver"]) + "\n"
      for user in sorted(self["users"], key=lambda s: s["username"].lower()):
        text += "  " + str(user["username"]).ljust(l["username"]) + str(user["fullname"]).ljust(l["fullname"]) + str(user["homeserver"]).ljust(l["homeserver"]) + "\n"
    return text

  def xml(self):
    group = ElementTree.Element('group')
    for field in self.__groupfieldsorder:
      if self.has_key(field) and self[field]:
        group.attrib[str(field)] = self[field]
    if self.has_key("users"):
      for user in sorted(self["users"], key=lambda s: s["username"].lower()):
        ElementTree.SubElement(group, 'user', attrib={"username":user["username"], "fullname":user["fullname"], "homeserver":user["homeserver"], } )
    return group

class zarafaGroups(object):
  def __init__(self, filter="*"):
    p = subprocess.Popen(['zarafa-admin', '-L'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err: raise IOError(err)
    data = str(out).split("\n")
    self.__groups = {}
    tmp=[]
    for item in range(len(data))[::-1]:      
      line = data[item]
      if len(line) < 1: continue
      if line[0] != '\t': continue
      line = re.sub( r"\t", "", line).strip().lower()
      if line == "everyone" or line == "groupname": continue
      if line[:10] == line[-10:]  == '-' * 10: continue
      tmp.append(line)
    for group in fnmatch.filter(tmp, filter):
      self.__groups[group] = zarafaGroup(group)

  groups   = property(fget = lambda self: self.__groups)

  def __contains__(self, group):
    return self.__groups.__contains__(self, str(group).lower())

  def __getitem__(self, group):
    grp = str(group).lower()
    if self.__groups.has_key(grp): return self.__groups[grp]
    raise KeyError(str(group))

  def __iter__(self):
    return self.__groups.iteritems()

  def __len__(self):
    return len(self.__groups)

  def has_key(self, group):
    return self.__groups.has_key(str(group).lower())

  def keys(self):
    return self.__groups.keys()

  def copy(self):
    return self.__groups.copy()

  def items(self):
    return self.__groups.items()

  def values(self):
    return self.__groups.values()

  def iteritems(self):
    return self.__groups.iteritems()

  def iterkeys(self):
    return self.__groups.iterkeys()

  def itervalues(self):
    return self.__groups.itervalues()

  def get(self, group):
    return self.__getitem__(group)

# Start program
if __name__ == "__main__":
  command_line_args()

  if args['output'] == "xml":
    xml = ElementTree.Element('results')

  if args['users']:
    users = zarafaUsers(args['object'])
    for user, data in users:
      if args['output'] == "xml":
        xml.append(data.xml())
        pass
      else:
        print data

  if args['groups']:
    groups = zarafaGroups(args['object'])
    for group, data in groups:
      if args['output'] == "xml":
        xml.append(data.xml())
      else:
        print data

  if args['output'] == "xml":
    print '<?xml version="1.0" encoding="' + encoding + '"?>'
    print ElementTree.tostring(xml, encoding=encoding, method="xml")
    