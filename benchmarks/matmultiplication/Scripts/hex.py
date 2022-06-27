#!/usr/bin/env python3

import config
import textwrap
import linecache as lc
import subprocess

infile=open('temphex','r')
outfile=open('temp.hex','w')
for lineno,line in enumerate(infile):
  if('@' in line):
    continue
  else:
    line=textwrap.wrap(line,8)
    for i in range(len(line)):
      outfile.write(line[i])
      outfile.write(",\n") 
    if(config.sperateInstrDataMemory==True):
      if('0000006f' in line):
        outfile.close();
        outfile=open('memory.hex','w');

infile.close()
outfile.close()

filenames = ['base.hex', 'temp.hex']
with open('code.coe', 'w') as outfile:
    for fname in filenames:
        with open(fname) as infile:
            for line in infile:
                outfile.write(line)
            infile.close()
outfile.close()



##########################################################
# Truncate code.coe to 262144 (+ 2 Lines) (1MB)
xmem_size = 262144 + 2
line_no=0
with open('xmem.coe', 'w') as outfile:
    with open('code.coe') as infile:
        for line in infile:
            if line_no < xmem_size:
                outfile.write(line)
                line_no = line_no + 1
            else:
                break
                print("xmem.coe Written Successfully")
    infile.close()
outfile.close()


