/* BASE.MSS CONTENTS
 * - Landuse & landcover
 * - Water areas
 * - Water ways
 * - Barriers
 * - Buildings
 *
 */

/* ================================================================== */
/* LANDUSE & LANDCOVER
/* ================================================================== */

#land-low[zoom>=0][zoom<10],
#land-high[zoom>=10] {
  polygon-fill: @land;
  polygon-gamma: 0.75;
}

#landuse_med,
#landuse_high {
  [type='leisure_common']        { polygon-fill: @park; }
  [type='landuse_forest']        { polygon-fill: @wooded; }
  [type='leisure_golf_course']   { polygon-fill: @grass; }

  [type='leisure_garden'],
  [type='landuse_grass'],
  [type='natural_grassland'] {
    polygon-fill: @grass;
  }

  [type='natural_glacier'] {
    polygon-fill: @glacier;
  }
  [type='natural_wetland'] {
    polygon-fill: @grass;
    polygon-pattern-file: url('symbols/openstreetmap-carto/wetland.png');
    polygon-pattern-alignment: global;
    polygon-pattern-opacity: 0.25;
  }
  [type='natural_sand'],
  [type='natural_beach'],
  [type='natural_dune'] {
    polygon-fill: @sand;
  }
  [type='natural_bare_rock'],
  [type='natural_scree'],
  [type='natural_shingle'] {
    polygon-fill: @bare_ground;
    polygon-pattern-file: url('symbols/openstreetmap-carto/scree_overlay.png');
    polygon-pattern-opacity: 0.8;
  }
  [type='natural_scrub'] {
    polygon-fill: @scrub;
  }
  [type='natural_heath']         { polygon-fill: @heath; }
  [type='amenity_hospital']      { polygon-fill: @hospital; }
  [type='landuse_vineyard'],
  [type='landuse_orchard'],
  [type='landuse_meadow']        { polygon-fill: @meadow; }
  [type='landuse_plant_nursery'] {
    polygon-fill: @meadow;
  }
  [type='landuse_allotments'] {
    polygon-fill: @grass;
  }

  [type='landuse_village_green'],
  [type='leisure_park'] {
    polygon-fill: @park;
  }

  [type='landuse_greenhouse_horticulture'],
  [type='landuse_farmland'] {
    polygon-fill: @farmland;
  }
  [type='natural_wood']          { polygon-fill: @wooded; }
}

#hillshade-low[zoom>1] {
  raster-scaling: bilinear;
  raster-comp-op: multiply;
  raster-opacity: 0.3;
}

#hillshade-high[zoom>=10] {
  raster-scaling: bilinear;
  raster-comp-op: multiply;
  raster-opacity: 0.25;
}

#landuse-overlay[type = 'wood'][zoom >= 13] {
  opacity: 0.4; // The entire layer has opacity to handle overlapping forests
}


/* ================================================================== */
/* WATER AREAS
/* ================================================================== */

Map { background-color: @water; }

#water_low,
#water_med,
#water_high {
  [intermittent = 'yes'] {
    polygon-pattern-file: url('symbols/openstreetmap-carto/intermittent_water.png');
  }
  [intermittent = 'no'] {
    polygon-fill: @water;
  }
}

/* ================================================================== */
/* WATER WAYS
/* ================================================================== */

#waterway_low[zoom>=11][zoom<=12] {
  line-color: @water;
  line-width: 1;
}

#waterway_med[zoom>=13][zoom<=14] {
  line-color: @water;
  [zoom = 13] { line-width: 0.5; }
  [zoom = 14] { line-width: 0.8; }

  [type='river'], [type='canal'] {
    [zoom = 13] { line-width: 1; }
    [zoom = 14] { line-width: 1.5; }
    line-cap: round;
    line-join: round;
  }

}

#piers-poly, #piers-line {
  [man_made = 'pier'][zoom >= 12] {
    #piers-poly {
      polygon-fill: @land;
    }
    #piers-line {
      line-width: 0.5;
      line-color: @land;
      line-cap: square;
      [zoom >= 13] { line-width: 1; }
      [zoom >= 15] { line-width: 2; }
      [zoom >= 17] { line-width: 4; }
    }
  }

  [man_made = 'breakwater'][zoom >= 12],
  [man_made = 'groyne'][zoom >= 12] {
    #piers-poly {
      polygon-fill: @land;
    }
    #piers-line {
      line-width: 1;
      line-color: @land;
      [zoom >= 13] { line-width: 2; }
      [zoom >= 16] { line-width: 4; }
    }
  }
}

/* ================================================================== */
/* Contours
/* ================================================================== */
.contours {
  line-color: @contours-color;
  line-smooth: 0.5;

  /* 100 m */
  #contours100 {
    [zoom >= 12] { line-width: 0.2; }
    [zoom >= 13] { line-width: 0.4; }
    [zoom >= 14] { line-width: 0.5; }
  }

  /* 50 m */
  #contours50 {
    [zoom >= 13] { line-width: 0.2; }
  }

  /* 20 m */
  #contours20 {
    [zoom >= 14] { line-width: 0.2;  }
  }

  /* All labels */

  #contours100[zoom >= 14],
  #contours50[zoom >= 16] {

      text-face-name: @standard-font;
      text-size: @contours-larger-font-size;
      text-fill: @contours-fill;
      text-halo-radius: 1;
      text-halo-fill: @contours-halo-fill;
      text-placement: line;
      text-label-position-tolerance: @contours-position-tolerance;
      text-spacing: @contours-spacing;
      text-min-path-length: @contours-min-path-length;
      text-max-char-angle-delta: @contours-max-char-angle-delta;
      text-name: "[ele]";
   
  }

  
}

/* ---- CLIFFS ---- */
#cliffs {
  [natural = 'cliff'][zoom >= 13] {
    line-pattern-file: url('symbols/openstreetmap-carto/cliff.svg');
    [zoom >= 15] {
      line-pattern-file: url('symbols/openstreetmap-carto/cliff2.svg');
    }
  }
  [man_made = 'embankment'][zoom >= 15]::man_made {
    line-pattern-file: url('symbols/openstreetmap-carto/embankment.svg');
  }
}

#barriers_line {
  [zoom >= 16] {
    line-width: 0.4;
    line-color: #444;
  }
  [feature = 'barrier_hedge'][zoom >= 16] {
    line-width: 1.5;
    line-color: @hedge;
    [zoom >= 17] {
      line-width: 2;
    }
    [zoom >= 18] {
      line-width: 3;
    }
    [zoom >= 19] {
      line-width: 4;
    }
    [zoom >= 20] {
      line-width: 5;
    }
  }
  [feature = 'historic_citywalls'],
  [feature = 'barrier_city_wall'] {
    [zoom >= 15] {
      line-width: 1;
      line-color: lighten(#444, 50%);
    }
    [zoom >= 16] {
      line-width: 1.5;
    }
    [zoom >= 17] {
      line-width: 2;
    }
    [zoom >= 18] {
      line-width: 3;
    }
    [zoom >= 19] {
      line-width: 4;
    }
    [zoom >= 20] {
      line-width: 5;
    }
  }
}

/* ---- BUILDINGS ---- */
#buildings[zoom>=16] {
  polygon-fill: @building;

  /* Thin contour of buildings in mid zooms important for gray background areas */
  line-color: darken(@building,10);
  line-width: 0.3;
  [zoom=17] {
    line-width: 0.5;
  }

  /* Render perimeter of buildings in high zooms */
  [zoom>=18] {
    line-color: darken(@building,20);
    line-width: 0.75;
  }
}
