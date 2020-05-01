import csv
import numpy as np
import re

fulldata = np.genfromtxt("periodStats.txt", delimiter=",", dtype=int, skip_header=1)

shift_file = open("periodShifts.txt", 'r')

shift_lens = dict()  

for line in shift_file.readlines():
  period_id = int(line[0:12])
  lens = re.split(r'=.([0-9]+\.[0-9]+)', line)
  if len(lens) < 2:
    print("line: " + line + "regex: " + str(lens))
  else:
    away_len = lens[1]
    home_len =  lens[3]
    shift_lens[period_id] = [home_len, away_len]

print("finished parsing data\nMerging lists...")
print("Number of period with shift data: " + str(len(shift_lens)))

outfile = open("periodCombined.txt", "w+")
outfile.write("periodID, period initial goal differential, blocked shots away, blocked shots home, faceoff away, faceoff home, giveaway away, giveaway home, hit away, hit home, missed shot away, missed shot home, penalty away, penalty home, shot away, shot home, takeaway away, takeaway home, av shift home, av shift away, period final goal differential")

count = 0
for i in range(len(fulldata)):
  dat = list(fulldata[i])
  if dat[0] in shift_lens:
    #print("orig data: " + str(dat))
    #print("Insert: " + str(shift_lens[dat[0]]))
    dat.insert(18, shift_lens[dat[0]][0])
    dat.insert(19, shift_lens[dat[0]][1])
    count += 1
    #print("mod data: " + str(dat))
  else:
    dat.insert(18, 0.0)
    dat.insert(19, 0.0)
  for j in range(len(dat)):
    if j == (len(dat) - 1):
      com = "\n"
    else:
      com = ","
    outfile.write(str(dat[j]) + com)

print("finished writing outfile, added period data to " + str(count) + " entries")
