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

rm -f $WARPFILE
rm -f $HILLFILE

echo ""
echo "************ Merging files with gdalwarp *****************"

cmd="gdalwarp \
  -co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE \
  -t_srs EPSG:3857 \
  -r bilinear \
  -tr $RESOLUTION $RESOLUTION \
  -srcnodata -32768 -dstnodata -32768 \
  --optfile $INFILE \
  $WARPFILE"
echo $cmd
$cmd


echo ""
echo "************ creating hillshade with gdaldem *****************"

cmd="gdaldem hillshade -z $ZFACTOR -compute_edges \
  -co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE \
  $WARPFILE $HILLFILE"
echo $cmd
$cmd
