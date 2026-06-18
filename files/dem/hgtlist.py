#########################################################
#
# Builds the list of the HGT files needed to cover the area defined by a polygon file
#
# arg1: the polygon file
# arg2: output file path
# arg3..N: one or more directories containing HGT files
#
#########################################################

import sys
import re
import os
import math


def lon2txt(lon):
    if lon >= 0 :
        return "E%03d" % lon
    else:
        return "W%03d" % -lon

def lat2txt(lat):
    if lat >= 0 :
        return "N%02d" % lat
    else:
        return "S%02d" % -lat

filepoly=sys.argv[1]
filelist=sys.argv[2]
hgtdirs=sys.argv[3:]   # one or more directories

# --- Parse all lon/lat points from the polygon file ---
lons = []
lats = []

f=open(filepoly,"r")
for line in f :

    if line[0] != " ":
        continue
    line=line.strip()
    line=re.sub(" +",";",line)
    lon,lat=line.split(";")
    lons.append(float(lon))
    lats.append(float(lat))
f.close()

# --- Compute bounding box with 1-degree buffer ---
# The buffer ensures tiles that only partially overlap the area are included,
# which is necessary to avoid missing hillshade at polygon edges.
BUFFER = 1
minlat = math.floor(min(lats)) - BUFFER
maxlat = math.floor(max(lats)) + BUFFER
minlon = math.floor(min(lons)) - BUFFER
maxlon = math.floor(max(lons)) + BUFFER

# --- For each tile in the bbox, find it in the hgtdirs ---
f=open(filelist,"w")
for lat in range(minlat, maxlat + 1):
    for lon in range(minlon, maxlon + 1):
        tilename = f'{lat2txt(lat)}{lon2txt(lon)}.hgt'
        found = False
        for hgtdir in hgtdirs:
            filename = f'{hgtdir}/{tilename}'
            if os.path.exists(filename):
                f.write(filename + "\n")
                found = True
        if not found:
            print( tilename + "=not found in any of: " + ", ".join(hgtdirs))
f.close()
print("filelist=", filelist)
