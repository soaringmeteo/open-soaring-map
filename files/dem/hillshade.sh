#####################################################
#
# build hillshade
#
# bash ../dem/hillshade.sh listfile.txt resolution zfactor
#
#####################################################

INFILE=$1
RESOLUTION=$2
ZFACTOR=$3


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

cmd="gdalwarp \
  -co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE \
  -t_srs EPSG:3857 \
  -r bilinear \
  -tr $RESOLUTION $RESOLUTION \
  -srcnodata -32768 -dstnodata -32768 \
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
