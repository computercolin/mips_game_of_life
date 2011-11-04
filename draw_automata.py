#!/bin/python
#
# Colin Zwiebel
# 2 Nov 2011

import os.path

new_mod = 0
while True:
  new_mod = os.path.getmtime("test.txt")
  if new_mod != old_mod:
    print "There is change in the air"
    # Do redraw loop
    old_mod = new_mod
