#####################################################
#
# build hillshade (two-pass: VIEW1 at native 30m, VIEW3 at native 90m, combined)
#
# bash ../dem/hillshade.sh v1list.txt v3list.txt resolution zfactor [polyfile]
#
#####################################################

V1INFILE=$1
V3INFILE=$2
RESOLUTION=$3
ZFACTOR=$4
POLYFILE=$5

V1_VRTFILE=merged-v1-$RESOLUTION.vrt
V1_WARPFILE=warp-v1-$RESOLUTION.tif
V1_HILLFILE=hillshade-v1-$RESOLUTION.tif
V3_VRTFILE=merged-v3-$RESOLUTION.vrt
V3_WARPFILE=warp-v3-$RESOLUTION.tif
V3_HILLFILE=hillshade-v3-$RESOLUTION.tif
COMBINED_VRT=hillshade-combined-$RESOLUTION.vrt
HILLFILE=hillshade-$RESOLUTION.tif

rm -f $V1_VRTFILE $V1_WARPFILE $V1_HILLFILE \
      $V3_VRTFILE $V3_WARPFILE $V3_HILLFILE \
      $COMBINED_VRT $HILLFILE

# VIEW3 is 3" ≈ 90m native; never warp it finer than that to avoid upsampling artifacts
V3_RESOLUTION=$RESOLUTION
if [ "$V3_RESOLUTION" -lt 90 ]; then V3_RESOLUTION=90; fi

TE_ARGS=""
if [ -f "$POLYFILE" ]; then
    set -- $(awk '
        /^[[:space:]]+-?[0-9]/ {
            if (!seen++) { minlon=$1; maxlon=$1; minlat=$2; maxlat=$2 }
            if ($1 < minlon) minlon=$1; if ($1 > maxlon) maxlon=$1
            if ($2 < minlat) minlat=$2; if ($2 > maxlat) maxlat=$2
        }
        END {
            lo = minlon-1 < -180   ? -180   : minlon-1
            hi = maxlon+1 >  180   ?  180   : maxlon+1
            bo = minlat-1 < -85.06 ? -85.06 : minlat-1
            bi = maxlat+1 >  85.06 ?  85.06 : maxlat+1
            print lo, bo, hi, bi
        }
    ' "$POLYFILE")
    MINLON=$1; MINLAT=$2; MAXLON=$3; MAXLAT=$4
    TE_ARGS="-te $MINLON $MINLAT $MAXLON $MAXLAT -te_srs EPSG:4326"
fi

WARP_OPTS="-co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE
  -t_srs EPSG:3857 -r bilinear -srcnodata -32768 -dstnodata -32768"

HILLSHADE_OPTS="-co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE"

#----------- VIEW1 pass -----------
if [ -s "$V1INFILE" ]; then
    echo ""
    echo "************ VIEW1: building VRT *****************"
    gdalbuildvrt -srcnodata -32768 -input_file_list $V1INFILE $V1_VRTFILE

    echo "************ VIEW1: warping to ${RESOLUTION}m *****************"
    gdalwarp $WARP_OPTS -tr $RESOLUTION $RESOLUTION $TE_ARGS $V1_VRTFILE $V1_WARPFILE

    echo "************ VIEW1: hillshade *****************"
    gdaldem hillshade -alt 60 -z $ZFACTOR -compute_edges $HILLSHADE_OPTS $V1_WARPFILE $V1_HILLFILE
else
    echo "WARNING: VIEW1 list is empty, skipping VIEW1 pass"
fi

#----------- VIEW3 pass -----------
if [ -s "$V3INFILE" ]; then
    echo ""
    echo "************ VIEW3: building VRT *****************"
    gdalbuildvrt -srcnodata -32768 -input_file_list $V3INFILE $V3_VRTFILE

    echo "************ VIEW3: warping to ${V3_RESOLUTION}m (native) *****************"
    gdalwarp $WARP_OPTS -tr $V3_RESOLUTION $V3_RESOLUTION $TE_ARGS $V3_VRTFILE $V3_WARPFILE

    echo "************ VIEW3: hillshade *****************"
    gdaldem hillshade -alt 60 -z $ZFACTOR -compute_edges $HILLSHADE_OPTS $V3_WARPFILE $V3_HILLFILE
else
    echo "WARNING: VIEW3 list is empty, skipping VIEW3 pass"
fi

#----------- Combine -----------
echo ""
echo "************ combining hillshades *****************"

if [ -f "$V1_HILLFILE" ] && [ -f "$V3_HILLFILE" ]; then
    # VIEW1 takes priority; where VIEW1 has nodata (=0), VIEW3 fills in.
    # -srcnodata 0 treats gdaldem's nodata output (0) as transparent so VIEW3 shows through.
    gdalbuildvrt -resolution highest -r bilinear -srcnodata 0 \
        $COMBINED_VRT $V3_HILLFILE $V1_HILLFILE
    gdal_translate \
        -co BIGTIFF=YES -co TILED=YES -co PREDICTOR=2 -co COMPRESS=DEFLATE \
        $COMBINED_VRT $HILLFILE
elif [ -f "$V1_HILLFILE" ]; then
    mv $V1_HILLFILE $HILLFILE
elif [ -f "$V3_HILLFILE" ]; then
    mv $V3_HILLFILE $HILLFILE
else
    echo "ERROR: no hillshade produced (both VIEW1 and VIEW3 lists are empty)"
    exit 1
fi

echo "Done: $HILLFILE"
