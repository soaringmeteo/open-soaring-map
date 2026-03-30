#!/bin/sh
# -----------------------------------------------------------------------
# bbox_buffer.sh  –  expand a bounding box by a buffer in degrees
#
# Usage:
#   bbox_buffer.sh <bboxfile> [buffer_degrees]
#
# Input file: a single line containing  minlon,minlat,maxlon,maxlat
# Output:     minlon,minlat,maxlon,maxlat  (with buffer applied to all sides)
#             ready to pass to  --bbox= (osmium extract)
#
# Example – contour clipping with 0.5° margin:
#   bbox_buffer.sh files/myfiles/wrf-domain.bbox 0.5
# -----------------------------------------------------------------------
set -e

BBOXFILE="$1"
BUFFER="${2:-0}"

if [ -z "$BBOXFILE" ]; then
    echo "Usage: $0 <bboxfile> [buffer_degrees]" >&2
    exit 1
fi

if [ ! -f "$BBOXFILE" ]; then
    echo "Error: file not found: $BBOXFILE" >&2
    exit 1
fi

# LC_ALL=C: ensures '.' is used as decimal separator regardless of locale,
# both for parsing the input values and for printf output.
LC_ALL=C awk -F, -v buffer="$BUFFER" '
    NR == 1 {
        printf "%.6f,%.6f,%.6f,%.6f\n",
            $1 - buffer, $2 - buffer,
            $3 + buffer, $4 + buffer
    }
' "$BBOXFILE"

