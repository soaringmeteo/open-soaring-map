#!/bin/sh
set -e

############################################################################################
# this script is executed from /osmhike 
############################################################################################

# databases names 
DB_OSM=osm
DB_CONTOURS=contours


# working directory for contours
mkdir -p demdata

# style directory
STYLE=./style
# export directory
EXPORT=./export

# data directory used by Kosmtik to download shapefiles
mkdir -p $STYLE/data
chmod a+rwX $STYLE/data

# the place where hgt files have been stored, depends on the source
# AREAPOLYSOURCE can be a comma-separated list (e.g. "view1,view3") for fallback
# Build HGTDIRS as a space-separated list of directories to look in
HGTDIRS=""
for _src in $(echo "$AREAPOLYSOURCE" | tr ',' '\n'); do
  case "$_src" in
    view1) HGTDIRS="$HGTDIRS hgt/VIEW1" ;;
    view3) HGTDIRS="$HGTDIRS hgt/VIEW3" ;;
    *)     HGTDIRS="$HGTDIRS hgt/${_src}" ;;
  esac
done
HGTDIRS=$(echo $HGTDIRS)   # trim leading space

#------------------- Testing if database is ready -----------------------
i=1
MAXCOUNT=60

echo "Waiting for PostgreSQL to be running"
while [ $i -le $MAXCOUNT ]
do
  if pg_isready -q; then echo "PostgreSQL running"; break; fi
  sleep 2
  i=$((i+1))
done
if [ $i -gt $MAXCOUNT ]; then echo "Timeout while waiting for PostgreSQL to be running"; fi


ACTION=$1
PARAM=$2

#############################################################
# function to create a database
#  $1: database name
#  $2,$3: if not empty, name of an extension to install
############################################################
CreateDatabase()
{
  psql -c "SELECT 1 FROM pg_database WHERE datname = '$1';" | grep -q 1 || createdb $1
  if [ "$2" != "" ]
  then
    psql -d $1 -c "CREATE EXTENSION IF NOT EXISTS $2;"
  fi
  if [ "$3" != "" ]
  then
    psql -d $1 -c "CREATE EXTENSION IF NOT EXISTS $3;"
  fi
}

#############################################################
# function to create the needed views
# must be called before running Kosmtik or Tirex, in case some features have been modified
#
############################################################
CreateViewsFunctions()
{

  echo "\nRun cyclosm-specific sql script to create some views"
  psql --dbname=$DB_OSM --file=$STYLE/views.sql

  # create specific sql file for road sizes
  bash scripts/zfact.sh $STYLE $DB_OSM

}

echo "\n===================ACTION=$ACTION====== `date '+%H:%M:%S'` ==================================="

case $ACTION in

#################### import OSM file to database #####################
import)

  echo "\n==================== working with AREA=$AREAOSM ================"

  echo "\n Creating default database + extensions"
  #psql -c "SELECT 1 FROM pg_database WHERE datname = '$DB_OSM';" | grep -q 1 || createdb $DB_OSM && \
  #psql -d $DB_OSM -c 'CREATE EXTENSION IF NOT EXISTS postgis;' && \
  #psql -d $DB_OSM -c 'CREATE EXTENSION IF NOT EXISTS hstore;' && \
  CreateDatabase $DB_OSM postgis hstore

  # if AREAOSM does not contain a directory, append "myfiles"
  if [ "`dirname $AREAOSM`" = "." ]
  then
     OSMFILE="./myfiles/$AREAOSM"
  else
     OSMFILE=$AREAOSM
  fi

  # Pre-filter the PBF to strip objects never queried by the Mapnik style
  # (buildings, barriers, power lines, address-only nodes …).
  # osmium tags-filter works as an allow-list: only objects matching an
  # expression in osmium-filter.txt are kept.
  OSMFILE_FILTERED="${OSMFILE%.pbf}-filtered.pbf"
  echo "\n  Pre-filtering OSM data with osmium  `date '+%H:%M:%S'`"
  osmium tags-filter \
    "$OSMFILE" \
    --expressions="$STYLE/osmium-filter.txt" \
    --overwrite \
    -o "$OSMFILE_FILTERED"
  echo "  Filtering done. Original: $(du -sh $OSMFILE | cut -f1)  Filtered: $(du -sh $OSMFILE_FILTERED | cut -f1)  `date '+%H:%M:%S'`"

  echo "\n  Importing data to  database, using osm2pgsql"
  osm2pgsql \
  --cache $OSM2PGSQL_CACHE \
  --number-processes $OSM2PGSQL_NUMPROC \
  --hstore \
  --database $DB_OSM \
  --slim \
  -c \
  -G \
  --drop  \
  "$OSMFILE_FILTERED"



  echo "\nCreate indexes to optimize performance `date '+%H:%M:%S'` "
  psql --dbname=$DB_OSM --file=$STYLE/zindex.sql

  # creation of Views/Functions
  CreateViewsFunctions
  echo ""
  echo "Finished !   `date '+%H:%M:%S'` "
  ;;

isolations)
  # download elevation files, and produce .osm.pbf contour file using pyhgtmap
  # run phyghtmap to download elevation files ( .hgt )  corresponding to $CONTOURS.poly
  # we use --source=view1 by default ,to download freely from  www.viewfinderpanoramas.org , rather than NASA which needs a very complex registration
  #  -s 10 produces contour lines with 10 meters interval
  #  output file will be AREAPOLY_lon_xxxx_lat_yyy.osm.pbf
  cd demdata
  POLYGON=../myfiles/$AREAPOLY
  echo ""
  echo "***************** run phyghtmap on file=$POLYGON  source=$AREAPOLYSOURCE  `date '+%H:%M:%S'` ********************"
  rm -f $AREAPOLY*.osm.pbf
  bash ../dem/pyhgtmap.sh  --polygon=$POLYGON -j 8 -s 10 -0 --source=$AREAPOLYSOURCE  --max-nodes-per-tile=0 --max-nodes-per-way=0 --pbf -o $AREAPOLY

  # run postprocessing tools
  echo "\nFill missing peak elevations and compute peak isolations  `date '+%H:%M:%S'` "
  echo "Merge .hgt files from $HGTDIRS"
  HGTFILES=""
  for _d in $HGTDIRS; do
    if ls ./$_d/*.hgt 1>/dev/null 2>&1; then
      HGTFILES="$HGTFILES ./$_d/*.hgt"
    fi
  done
  gdal_merge.py -o ./dem-srtm.tiff -of GTiff $HGTFILES
  echo "Update isolations in database"
  /osmhike/docker/postprocessing/update_isolations.sh $DB_OSM
  #echo "Update saddle directions in database"
  #/osmhike/docker/postprocessing/update_saddles.sh $DB_OSM

  echo ""
  echo "Finished !   `date '+%H:%M:%S'` " 
  #echo "Finished !  This container will sleep for a long time, doing nothing . You can stop it without damage with CTRL/C"
  #echo "You can inspect its contents and database, by typing in another shell window:"
  #echo "    docker exec -it c-import  bash"
  #sleep 10000

  ;;

city_isolations)
  echo "Compute city isolations"
  psql -d $DB_OSM --file=/osmhike/docker/postprocessing/city_isolation.sql
  ;;

######################## create the database containing contours ############
contours)

  # CAUTION : before calling this:
  #           * a polygon file $AREAPOLY.poly   is to be downloaded from geobabrik  ( typically  wget http://download.geofabrik.de/europe/andorra.poly )
  #             it contains a list of lon/lat coordinates that define the perimeter for which we build contours

  # go to specific directory
  cd demdata


  # create another database "contours"  and store contour lines , using osm2pgsql
  # in this database, contour lines will be in table "planet_osm_line" , using column "ele" to store height value
  echo "\n**************** CONTOURS STEP2: use osm2pgsql to import data  `date '+%H:%M:%S'` *******************\n"

  # Determine the PBF to import.
  # If HIGHRESAREAPOLY is set, clip the full pyhgtmap output to that polygon
  # (+ 0.5° buffer) before importing. Contours are only rendered from zoom 12
  # and only within the high-res export area, so importing the whole world would
  # waste disk space and slow down every tile-render query.
  PBF_INPUT="./$AREAPOLY*.osm.pbf"
  if [ -n "$HIGHRESAREABBOX" ]; then
    echo "\n*** Clipping contours to high-res area: $HIGHRESAREABBOX (+ 0.5° buffer) ***"
    BBOX=$(sh ../scripts/bbox_buffer.sh ../myfiles/$HIGHRESAREABBOX 0.5)
    echo "    Clipping bbox: $BBOX"
    CLIPPED_PBF="./contours-clipped.osm.pbf"
    # pyhgtmap is invoked with --max-nodes-per-tile=0 --max-nodes-per-way=0, so it
    # always produces exactly one PBF file; the glob always expands to a single path.
    osmium extract --bbox="$BBOX" --overwrite -o "$CLIPPED_PBF" ./$AREAPOLY*.osm.pbf
    PBF_INPUT="$CLIPPED_PBF"
  fi

  CreateDatabase $DB_CONTOURS postgis

  osm2pgsql --slim --drop -d $DB_CONTOURS    --cache $OSM2PGSQL_CACHE --style ../dem/contours.style $PBF_INPUT



  echo "\n------------------------- Create indexes to optimize performance `date '+%H:%M:%S'` --------------------"
  psql --dbname=$DB_CONTOURS --file=../dem/zindexcontours.sql

  echo "\n--------------------Table and Index sizes --------------------\n"
  psql --dbname=$DB_CONTOURS -c "\dt+"
  psql --dbname=$DB_CONTOURS -c "\di+"

  echo ""
  echo "Finished !  Contours have been generated `date '+%H:%M:%S'` "

  ;;

############################ generate file containing hillshade ##########################
hillshade)

  cd demdata

  echo ""
  echo "************** Build the list of needed .hgt files from $HGTDIRS `date '+%H:%M:%S'` ****************"

  python3 ../dem/hgtlist.py ../myfiles/$AREAPOLY $HGTDIRS

  # process needed file for required resolution
  # this action can be repeated with different resolutions

  echo "\n######################## compute hillshade RESOLUTION=500 ###########################\n"
  sh ../dem/hillshade.sh $AREAPOLY.txt 500 8 ../myfiles/$AREAPOLY   # low resolution

  echo "\n######################## compute hillshade RESOLUTION=30 ###########################\n"
  sh ../dem/hillshade.sh $AREAPOLY.txt 30  7 ../myfiles/$AREAPOLY   # high resolution

  echo "\nFinished !  Hillshade have been generated `date '+%H:%M:%S'` "
  ;;


####################### Create the Legend : part1 ###############################
legend1)

      echo "\n==================== create the Legend osm file and import it to database  ==========="

      echo "\n------------ Creating  database with extensions ---------------"
      CreateDatabase $DB_OSM postgis hstore
      #psql -c "SELECT 1 FROM pg_database WHERE datname = '$DB_OSM';" | grep -q 1 || createdb $DB_OSM && \
      #psql -d $DB_OSM -c 'CREATE EXTENSION IF NOT EXISTS postgis;' && \
      #psql -d $DB_OSM -c 'CREATE EXTENSION IF NOT EXISTS hstore;' && \

      OSMLEGEND="legend/legend.osm"
      echo "\n------------ Create legend osm file : $OSMLEGEND ---------------"

      python3 legend/makelegend.py osm
      

      echo "\n------------ Import legend file to database  ---------------"
      osm2pgsql --hstore --slim -c -G --drop --database $DB_OSM  $OSMLEGEND

      # creation of Views/Functions
      CreateViewsFunctions

      echo "\n------------ finished !  ---------------"
      ;;

####################### Create the Legend : part2 ###############################
legend2)


      echo "\n==================== Create the Legend jpg file   ==========="

      python3 legend/makelegend.py jpg


   echo "\n------------ finished !  ---------------"
   ;;

############################ Kosmtik rendering server ##################
kosmtik)

  # Starting Kosmtik
  export KOSMTIK_CONFIGPATH="/tmp/.kosmtik-config.yml"

  # creation of views/Functions
  CreateViewsFunctions


  # tile web server
  kosmtik serve $STYLE/project.mml --host 0.0.0.0
  # It needs Ctrl+C to be interrupted


;;

############################ Kosmtik : just produce mapnik  .xml file ##################
xml)
  echo "----------- Kosmtik: produce project.xml file ---------------"
  #kosmtik -h
  kosmtik export $STYLE/project.mml --output $STYLE/project.xml
  ;;

############################  Kosmtik : export tiles ############
export-tiles)
  echo "----------- Kosmtik: export tiles ---------------"
  export KOSMTIK_CONFIGPATH="/tmp/.kosmtik-config.yml"

  # creation of views/Functions
  CreateViewsFunctions

  kosmtik export \
    $STYLE/project.mml \
    --output $EXPORT \
    --format tiles \
    --tileFormat "webp:quality=80" \
    $*
  ;;

################### any other values is command+parameters to execute
*)
  "$@"
  ;;


esac
