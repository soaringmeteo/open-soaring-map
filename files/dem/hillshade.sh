#####################################################
#
# build hillshade
#
# bash ../dem/hillshade.sh listfile.txt resolution zfactor [polyfile]
#
#####################################################

INFILE=$1
RESOLUTION=$2
ZFACTOR=$3
POLYFILE=$4


WARPFILE=warp-$RESOLUTION.tif
HILLFILE=hillshade-$RESOLUTION.tif
VRTFILE=merged-$RESOLUTION.vrt

rm -f $WARPFILE $HILLFILE $VRTFILE

# Guard: skip gracefully if no HGT files were found for this area
if [ ! -s $INFILE ]; then
    echo "WARNING: no HGT files found, skipping hillshade for resolution $RESOLUTION"
    exit 0
fi

# Build VRT index from file list (avoids shell ARG_MAX limit)
gdalbuildvrt -srcnodata -32768 -input_file_list $INFILE $VRTFILE

echo ""
echo "************ Merging files with gdalwarp *****************"

TE_ARGS=""
if [ -f "$POLYFILE" ]; then
    set -- $(awk '
        /^[[:space:]]+-?[0-9]/ {
            if (!seen++) { minlon=$1; maxlon=$1; minlat=$2; maxlat=$2 }
            if ($1 < minlon) minlon=$1; if ($1 > maxlon) maxlon=$1
            if ($2 < minlat) minlat=$2; if ($2 > maxlat) maxlat=$2
        }
        END { print minlon-1, minlat-1, maxlon+1, maxlat+1 }
    ' "$POLYFILE")
    MINLON=$1; MINLAT=$2; MAXLON=$3; MAXLAT=$4
    TE_ARGS="-te $MINLON $MINLAT $MAXLON $MAXLAT -te_srs EPSG:4326"
fi

cmd="gdalwarp \
  -co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE \
  -t_srs EPSG:3857 \
  -r bilinear \
  -tr $RESOLUTION $RESOLUTION \
  -srcnodata -32768 -wo INIT_DEST=0 \
  $TE_ARGS \
  $VRTFILE $WARPFILE"
echo $cmd
$cmd


echo ""
echo "************ creating hillshade with gdaldem *****************"

cmd="gdaldem hillshade -z $ZFACTOR -compute_edges \
  -co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE \
  $WARPFILE $HILLFILE"
echo $cmd
$cmd
