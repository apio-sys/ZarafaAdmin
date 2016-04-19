#!/usr/bin/env python
"""
Python utility classes
"""

class listOfType(list):

  def __convertItem(self, item):
    if self.__dataType: item =  self.__dataType(item)
    return item

  def __format(self, items = None):
    if not items: items = self
    if self.__unique:
      for item in items:
        if items.count(item) > 1: 
          items.remove(item)
    if self.__sorted: items.sort()
    return items

  def __init__(self, items = None, dataType = None, sorted = False, unique = False, debug = False, errors = False):
    self.__dataType = None    
    if str(type(dataType)).split("'")[1] in ['function','type']: self.__dataType = dataType
    self.__sorted = bool(sorted)
    self.__unique = bool(unique)
    self.__debug = bool(debug)
    self.__errors = bool(errors)
    if items:
      tmp = [ self.__convertItem(item) for item in list(items) ]
    else:
      tmp = []

    super( listOfType, self ).__init__(self.__format(tmp))

  dataType = property(fget = lambda self: self.__dataType)
  sorted = property(fget = lambda self: self.__sorted)
  unique = property(fget = lambda self: self.__unique)
  debug = property(fget = lambda self: self.__debug)
  errors = property(fget = lambda self: self.__errors)

  def __setitem__(self, index, item):
    tmp = self.__convertItem(item)
    if self.__unique and tmp in self:
      pass
    else:
      super( listOfType, self ).__setitem__(index, tmp)
      if self.__sorted: tmp.sort()
    return self

  def __setslice__(self, index, index2, items):
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    super( listOfType, self ).__setslice__(index, index2, tmp)
    return self.__format()

  def __add__(self, items):
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    super( listOfType, self ).__add__(tmp)
    return self.__format()

  def __radd__(self, items):
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    super( listOfType, self ).__radd__(tmp)
    return self.__format()

  def __iadd__(self, items): 
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    super( listOfType, self ).__iadd__(tmp)
    return self.__format()

  def append(self, item): 
    super( listOfType, self ).append(self.__convertItem(item))
    return self.__format()

  def extend(self, items): 
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    super( listOfType, self ).extend(tmp)
    return self.__format()

  def insert(self, index, item): 
    super( listOfType, self ).insert(index, self.__convertItem(item))
    return self.__format()

  def union(self, items):
    """ Return elements which are in self or in any of the lists."""
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    return list(set(self).union(tmp))

  def intersection(self, items):
    """ Return elements which are in self and in all of the lists."""
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    return list(set(self).intersection(tmp))

  def difference(self, items):
    """ Return elements which are in self and and not in any of the lists."""
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    return list(set(self).difference(tmp))

  def symmetric_difference(self, items):
    """ Return elements which are in self or l but not both."""
    tmp = listOfType(items, dataType = self.__dataType, sorted = self.__sorted, unique = self.__unique, debug = self.__debug, errors = self.__errors)
    return list(set(self).symmetric_difference(tmp))

class dictOfType(dict):
  def __convertKey(self, key):
    if self.__keyType: key = self.__keyType(key)
    return key 

  def __convertValue(self, value):
    if self.__valueType: value = self.__valueType(value)
    return value

  def __init__(self, data = None, keyType = None, valueType = None, debug = False, errors = False):
    self.__keyType = None
    self.__valueType = None
    if str(type(keyType)).split("'")[1] in ['function','type']: self.__keyType = keyType
    if str(type(valueType)).split("'")[1] in ['function','type']: self.__valueType = valueType
    self.__debug = bool(debug)
    self.__errors = bool(errors)

    super( dictOfType, self ).__init__()
    if data:
      for key, value in data.iteritems(): self[key] = value

  keyType = property(fget = lambda self: self.__keyType)
  valueType = property(fget = lambda self: self.__valueType)
  debug = property(fget = lambda self: self.__debug)
  errors = property(fget = lambda self: self.__errors)

  def __setitem__(self, key, value):
    return super( dictOfType, self ).__setitem__(self.__convertKey(key), self.__convertValue(value))

  def __getitem__(self, key):
    return super( dictOfType, self ).__getitem__(self.__convertKey(key))

  def __delitem__(self, key):
    return super( dictOfType, self ).__delitem__(self.__convertKey(key))

  def has_key(self, key):
    return super( dictOfType, self ).has_key(self.__convertKey(key))

  def update(self, data):
    tmp = dictOfType(data, keyType = self.__keyType, valueType = self.__valueType, debug = self.__debug, errors = self.__errors)
    return super( dictOfType, self ).update(tmp)

  def __add__(self, data):
    return self.update(data)

  def __radd__(self, data):
    return self.update(data)

  def __iadd__(self, data):
    return self.update(data)

  def get(self, key, default = None):
    if default:
      return super( dictOfType, self ).get(self.__convertKey(key), self.__convertValue(default))
    else:
      return super( dictOfType, self ).get(self.__convertKey(key))

  def setdefault(self, key, value = None):
    if value and not self.has_key(key): self[key] = value
    return self.get(key, value)





class structDict(dictOfType):
  def __convertKey(self, key):
    key = str(key).strip(' \t\n\r')
    if self.__keylower: key = str(key).lower()
    if self.__keymap:
      if self.__keymap.has_key(key):
        key = self.__keymap[key]
      else:
        key = None

  def parse(self, text):
    self.__comment = []
    self.__unparsed = []
    commentchar = str(self.__commentchar).strip()
    for line in str(text).split("\n"):
      if not line: continue
      if line[0] in self.__commentchar: 
        self.__comment.append(line)
        continue
      if not self.__commentchar in line: 
        self.__unparsed.append(line)
        continue
      key, value = line.split(self.__commentchar, 1)
      key = self.__convertKey(key)
      value = value.strip(' \t\n\r')
      if key:
        self[key] = value
      else:
        self.__unparsed.append(line)

  def __init__(self, text = None, keylower = False, delimiter = "=", comment = "#;", keymap=None, debug = False, errors = False):
    self.__delimiter = "="
    if delimiter: self.__delimiter = str(delimiter)[0]
    self.__delimiter = "#;"
    if self.__commentchar: self.__commentchar = str(comment).strip(' \t\n\r')
    self.__keylower = bool(keylower)
    self.__keymap = None
    if self.__keymap: self.__keymap = dict(keymap)
    self.__comment = []
    self.__unparsed = []
    super( structuredText, self ).__init__(self, data = None, keyType = None, valueType = str, debug = debug, errors = errors)
    if text: self.parse(text)

  delimiter = property(fget = lambda self: self.__delimiter)
  commentchar = property(fget = lambda self: self.__commentchar)
  keylower = property(fget = lambda self: self.__keylower)
  keymap = property(fget = lambda self: self.__keymap)
  comment = property(fget = lambda self: "\n".join(self.__comment))
  unparsed = property(fget = lambda self: "\n".join(self.__unparsed))

  def str(self,separator = " = ", keyType = None, keyorder = None):
    if not keyorder: keyorder = sorted(self.keys())
    if not str(type(keyType)).split("'")[1] in ['function','type']: keyType = str
    separator = str(separator)
    seen = []
    tmp = []

    for key in keyorder:
      tmp.append(keytype(key) + separator + self[key])
      seen.append(key)
    for key in sorted(set(self.keys()).difference(seen)):
      tmp.append(keytype(key) + separator + self[key])
    return tmp


