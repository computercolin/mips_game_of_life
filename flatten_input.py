#!/bin/python

import sys

if len(sys.argv) != 3:
    sys.exit("Usage: flatten_input.py board_in flattened_board_out")

fin_name = sys.argv[1]
fout_name = sys.argv[2]


fin = open(fin_name)
rows = list()
for line in fin:
  if line == "\n":
    continue
  rows.append(line)
fin.close()
m = len(rows)
n = len(rows[0]) -1
print m, n

fout = open(fout_name, 'w')
fout.write("%s%s" % (chr(m), chr(n)))
for row in rows:
	fout.write(row[0:-1])
fout.close()
