#!/bin/bash
#
# Two-step peak isolation update:
#
# Step 1 – Fill missing elevations:
#   For peaks/volcanoes whose ele tag is absent or non-numeric, sample the
#   merged SRTM DEM raster at the peak's coordinates using gdallocationinfo
#   and write the result back to the database.
#
# Step 2 – Compute isolations via SQL:
#   Run peak_isolation.sql, which uses a PostGIS LATERAL join + <-> KNN
#   operator to find, for each peak, the nearest peak with equal or greater
#   elevation.  The result is stored in otm_isolation (metres, rounded integer
#   stored as TEXT).  Peaks with no higher neighbour within the dataset receive
#   a fallback isolation of 50 000 m (50 km radius).
#
# If otm_isolation doesn't exist it will be created.
#


DBname=$1
demfile='demdata/dem-srtm.vrt'

cd /osmhike


###### Prepare #########
#
# Check if otm_isolation is a column of planet_osm_point, if not, create it
#

column=`psql -d $DBname -t -c "SELECT attname FROM pg_attribute \
         WHERE attrelid = ( SELECT oid FROM pg_class WHERE relname = 'planet_osm_point' ) \
         AND attname = 'otm_isolation';"`

if [ "$column" != " otm_isolation" ] ; then
 psql -d $DBname -c "ALTER TABLE planet_osm_point ADD COLUMN otm_isolation text;"
fi

#
# Check once again. If the column doesn't exist -> EXIT
#

column=`psql -d $DBname -t -c "SELECT attname FROM pg_attribute \
         WHERE attrelid = ( SELECT oid FROM pg_class WHERE relname = 'planet_osm_point' ) \
         AND attname = 'otm_isolation';"`

if [ "$column" != " otm_isolation" ] ; then
 echo "Sorry, no column otm_isolation in planet_osm_point"
 exit 1
fi


########## Step 1: Fill missing elevations from DEM ###########
#
# Query peaks/volcanoes whose ele is NULL or not a valid number.
# For each, sample the DEM raster with gdallocationinfo and emit an UPDATE.
# All UPDATEs are piped into a single psql transaction.
#

echo "Step 1: Filling missing peak elevations from DEM..."

(
  echo "BEGIN;"
  psql -A -t -F ";" -d $DBname -c \
    "SELECT osm_id,
            ST_X(ST_Transform(way, 4326)),
            ST_Y(ST_Transform(way, 4326))
     FROM planet_osm_point
     WHERE \"natural\" IN ('peak', 'volcano')
       AND (ele IS NULL OR ele !~ '^-?[0-9]+(\.[0-9]+)?$')" \
  | while IFS=";" read -r id lon lat; do
      val=$(gdallocationinfo -wgs84 -valonly "$demfile" "$lon" "$lat" 2>/dev/null)
      if [ -n "$val" ]; then
        echo "UPDATE planet_osm_point SET ele='$val' WHERE osm_id=$id;"
      fi
    done
  echo "COMMIT;"
) | psql -d $DBname


########## Step 2: Compute isolations via SQL ###########

echo "Step 2: Computing peak isolations via SQL..."
psql -d $DBname --file=/postprocessing/peak_isolation.sql
