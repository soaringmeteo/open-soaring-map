//=================================================================
// labels for items other than amenities
//  area , waterway, mountain peak/saddle/cave , roads/path , Bicycle route 
//===================================================================


// =====================================================================
// AREA LABELS
// =====================================================================

#area_label {
  // Bring in labels gradually as one zooms in, bases on polygon area
  [zoom=10][area>32000000],
  [zoom=11][area>16000000],
  [zoom=12][area>8000000],
  [zoom=13][area>4000000],
  [zoom=14][area>2000000],
  [zoom=15][area>100000],
  [zoom=16][area>50000],
  [zoom=17][area>25000],
  [zoom>=18] {
    text-name: "[name]";
    text-halo-radius: @standard-halo-radius;
    text-face-name:@sans;
    text-size: 11;
    text-wrap-width: 30;
    text-fill: #888;
    text-halo-fill: @standard-halo-fill;
    text-placement: interior;

    // Specific style overrides for different types of areas:
    [type='forest'],
    [type='wood'],
    [type='grass'],
    [type='common'],
    [type='park'] {
      text-face-name: @sans_italic;
      text-fill: @park * 0.6;
      text-halo-fill: lighten(@park, 10%);
    }
    [type='golf_course'] {
      text-fill: @grass * 0.6;
      text-halo-fill: lighten(@grass, 10%);
    }
    [type='basin'],
    [type='water'] {
      text-fill: @water * 0.6;
      text-halo-fill: lighten(@water, 10%);
    }
    [type='marina'] {
      text-fill: @water * 0.5;
      text-halo-fill: lighten(@water, 10%);
      text-face-name: @sans_italic;
    }
    [type='national_park'],
    [type='aboriginal_lands'],
    [type='protected_area'],
    [type='nature_reserve'] {
      text-face-name: @sans_italic;
      text-fill: @nature_reserve;
    }
    [type='military'] {
      text-fill: @military * 0.6;
      text-face-name: @sans_italic;
    }

    // text size adjustement regarding area size:
    [zoom=15][area>1600000],
    [zoom=16][area>80000],
    [zoom=17][area>20000],
    [zoom=18][area>5000] {
        text-name: "[name]";
        text-size: 13;
        text-wrap-width: 60;
        text-character-spacing: 1;
        text-halo-radius: 2;
    }
    [zoom=16][area>1600000],
    [zoom=17][area>80000],
    [zoom=18][area>20000] {
        text-size: 15;
        text-character-spacing: 2;
        text-wrap-width: 120;
    }
    [zoom>=17][area>1600000],
    [zoom>=18][area>80000] {
        text-size: 20;
        text-character-spacing: 3;
        text-wrap-width: 180;
    }
  }
}


/* ================================================================== */
/* WATERWAY LABELS
/* ================================================================== */

#waterway_label[type='river'][zoom>=13],
#waterway_label[type='canal'][zoom>=15],
#waterway_label[type='stream'][zoom>=17] {
  text-name: '[name]';
  text-face-name: @sans_italic;
  text-fill: @water * 0.75;
  text-halo-fill: fadeout(lighten(@water,5%),25%);
  text-halo-radius: @standard-halo-radius;
  text-placement: line;
  text-min-distance: 400;
  text-size: 10;
  [type='river'][zoom=15],
  [type='canal'][zoom=17] {
    text-size: 11;
  }
  [type='river'][zoom>=16],
  [type='canal'][zoom=18] {
    text-size: 14;
    text-spacing: 300;
  }
}

//==============================================================
// peak,saddle,cave,hut....
// =============================================================
#mountain-point-text[zoom = 8][isolation > 40000],
#mountain-point-text[zoom = 9][isolation > 20000],
#mountain-point-text[zoom = 10][isolation > 12000],
#mountain-point-text[zoom = 11][isolation > 7000],
#mountain-point-text[zoom = 12][isolation > 4000],
#mountain-point-text[zoom = 13][isolation > 1000],
#mountain-point-text[zoom = 14][isolation > 500],
#mountain-point-text[zoom = 15][isolation > 100]  {
    marker-file: url(symbols/openstreetmap-carto/natural/peak.svg);
    marker-placement: interior;
    marker-height: 4;
    marker-width: 7;
    marker-fill: white;
    marker-line-color: black;
    marker-line-width: 1;
    text-name: "[name]";
    [zoom <= 10][isolation > 30000],
    [zoom >= 11][isolation > 10000],
    [zoom >= 13][isolation > 2000] {
      text-name: [name]+" "+[elevation]+"\u00A0m";
    }
    text-size: 11;
    text-wrap-width: @standard-wrap-width;
    text-line-spacing: @standard-line-spacing-size;
    text-fill: black;
    text-dy: 5;
    text-face-name: @standard-font;
    text-halo-radius: @standard-halo-radius * 1.5;
    text-halo-fill: @standard-halo-fill;
    text-placement: point;  
    text-placement-type: simple;
    text-placements: "S,N,E,W,NE,SE,NW,SW";
    text-allow-overlap: false;
}
