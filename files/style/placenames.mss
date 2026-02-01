/*
    This file is taken and adapted from
    https://github.com/gravitystorm/openstreetmap-carto/blob/1bed8cc96a99105ad446fbcbb9fb00a23f44bfcc/placenames.mss.
    Original file licensed under CC0 public domain.

    It has then been adapted for Osmhike
*/

#country-names {
  [zoom >= 3][zoom < 5][way_pixels > 1000],
  [zoom >= 5][way_pixels < 360000] {
    text-name: "[name]";
    text-face-name: @sans_bold;
    text-size: 10;
    text-wrap-width: 35; // 3.5 em
    text-line-spacing: -1.5; // -0.15 em
    text-margin: 7.0; // 0.7 em

    text-placement-type: simple;
    text-placements: "C,N,S,E,W,NW,NE,SE";
    text-dx: 25;
    text-dy: 20;

    [zoom >= 4] {
      text-size: 11;
      text-wrap-width: 40; // 3.6 em
      text-line-spacing: -1.4; // -0.13 em
      text-margin: 7.7; // 0.7 em
    }
    [zoom >= 5] {
      text-size: 12;
      text-wrap-width: 45; // 3.8 em
      text-line-spacing: -1.2; // -0.10 em
      text-margin: 8.4; // 0.7 em
    }
    [zoom >= 7] {
      text-size: 13;
      text-wrap-width: 50; // 3.8 em
      text-line-spacing: -1.0; // -0.08 em
      text-margin: 9.1; // 0.7 em
    }
    [zoom >= 10] {
      text-size: 14;
      text-wrap-width: 55; // 3.9 em
      text-line-spacing: -0.7; // -0.05 em
    }
    text-fill: @country_text;
    text-face-name: @sans;
    text-halo-fill: @country_halo;
    text-halo-radius: @standard-halo-radius * 1.5;
    text-placement: interior;
    text-character-spacing: 0.5;
  }
}


#capital-names {
  [zoom >= 4][zoom < 8][population > 600000],
  [zoom >= 5][zoom < 8] {
    text-name: '[name]';
    text-face-name: @sans;
    text-wrap-width: 30; // 2.7 em
    text-line-spacing: -1.6; // -0.15 em
    text-margin: 7.7; // 0.7 em
    text-halo-fill: @city_halo;
    text-halo-radius: @standard-halo-radius * 1.5;
    text-placement-type: simple;
    text-placements: 'S,N,E,W';
    [dir = 1] {
      text-placements: 'N,S,E,W';
    }

    [zoom >= 5] {
      text-wrap-width: 45; // 4.1 em
      text-line-spacing: -1.1; // -0.10 em
    }
    [zoom >= 6] {
      text-size: 15;
      text-wrap-width: 60; // 5.0 em
      text-line-spacing: -0.6; // -0.05 em
      text-margin: 8.4; // 0.7 em
    }
    [zoom >= 7] {
      text-dx: 7;
      text-dy: 7;
    }
  }
  [zoom >= 8] {
    text-name: '[name]';
    text-face-name: @sans;
    text-fill: @placenames;
    text-size: 13;
    text-wrap-width: 65; // 5.0 em
    text-line-spacing: -0.65; // -0.05 em
    text-margin: 9.1; // 0.7 em
    text-halo-fill: @city_halo;
    text-halo-radius: @standard-halo-radius * 1.5;

    [zoom >= 10] {
      text-size: 14;
      text-wrap-width: 70; // 5.0 em
      text-line-spacing: -0.70; // -0.05 em
      text-margin: 9.8; // 0.7 em
    }
    [zoom >= 11] {
      text-size: 15;
      text-wrap-width: 75; // 5.0 em
      text-line-spacing: -0.75; // -0.05 em
      text-margin: 10.5; // 0.7 em
    }
  }
}

#placenames-medium::high-importance {
  /* Marseille */
  [category = 1][score >= 400000][zoom < 14] {
    text-name: '[name]';
    text-face-name: @sans;
    text-fill: @placenames;
    text-dx: 0;
    text-dy: 0;
    [zoom >= 5][zoom < 8] {
      text-wrap-width: 30; // 2.7 em
      text-line-spacing: -1.65; // -0.15 em
      text-margin: 7.7; // 0.7 em
      text-halo-fill: @city_halo;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-placement-type: simple;
      text-placements: 'S,N,E,W';
      [dir = 1] {
        text-placements: 'N,S,E,W';
      }

      [zoom >= 5] {
        text-wrap-width: 45; // 4.1 em
        text-line-spacing: -1.1; // -0.10 em
      }
      [zoom >= 6] {
        text-wrap-width: 60; // 5.0 em
        text-line-spacing: -0.6; // -0.05 em
      }

    }
    [zoom >= 8] {
      text-size: 13;
      text-wrap-width: 65; // 5.0 em
      text-line-spacing: -0.65; // -0.05 em
      text-margin: 9.1; // 0.7 em
      text-halo-fill: @city_halo;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-placement-type: simple;
      // FIXME: https://github.com/mapnik/mapnik/commit/4eae86b7bc750a08a7ab103a780d6b4bf951e1b1
      // text-placements: "C,N,S,E,W,NW,NE,SE";
      text-placements: "N,S,E,W,NW,NE,SE";

      [zoom >= 10] {
        text-size: 14;
        text-wrap-width: 70; // 5.0 em
        text-line-spacing: -0.7; // -0.05 em
        text-margin: 9.8; // 0.7 em
      }
      [zoom >= 11] {
        text-size: 15;
        text-wrap-width: 75; // 5.0 em
        text-line-spacing: -0.75; // -0.05 em
        text-margin: 10.5; // 0.7 em
      }
    }
  }
}

#placenames-medium::medium-importance {
  /* Avignon, Toulon, Aix-en-Provence */
  [category = 1][score < 400000][zoom >= 7][zoom < 15] {
    [zoom >= 7][zoom < 8][score >= 200000] {
      text-name: "[name]";
      text-fill: @placenames;
      text-face-name: @sans;
      text-halo-fill: @city_halo;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-dx: 0;
      text-dy: 0;
      text-size: 11;
      text-wrap-width: 30; // 3.0 em
      text-line-spacing: -1.5; // -0.15 em
      text-margin: 7.0; // 0.7 em
      text-placement-type: simple;
      text-placements: 'S,N,E,W';
      [dir = 1] {
        text-placements: 'N,S,E,W';
      }
    }
    [zoom >= 8] {
      text-name: "[name]";
      text-fill: @placenames;
      text-face-name: @sans;
      text-halo-fill: @city_halo;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-size: 12;
      text-wrap-width: 40; // 4.0 em
      text-line-spacing: -1.0; // -0.10 em
      text-margin: 7.0; // 0.7 em
      text-placement-type: simple;
      // FIXME: https://github.com/mapnik/mapnik/commit/4eae86b7bc750a08a7ab103a780d6b4bf951e1b1
      // text-placements: "C,N,S,E,W,NW,NE,SE";
      text-placements: "N,S,E,W,NW,NE,SE";
      text-dx: 0;
      text-dy: 0;
      [zoom >= 9] {
        text-size: 12;
        text-wrap-width: 60; // 5.0 em
        text-line-spacing: -0.6; // -0.05 em
        text-margin: 8.4; // 0.7 em
      }
      [zoom >= 10] {
        text-size: 13;
        text-wrap-width: 65; // 5.0 em
        text-line-spacing: -0.65; // -0.05 em
        text-margin: 9.1; // 0.7 em
      }
      [zoom >= 11] {
        text-size: 14;
        text-wrap-width: 70; // 5.0 em
        text-line-spacing: -0.7; // -0.05 em
        text-margin: 9.8; // 0.7 em
      }
      [zoom >= 14] {
        text-size: 15;
        text-wrap-width: 75; // 5.0 em
        text-line-spacing: -0.7; // -0.05 em
        text-margin: 10.5; // 0.7 em
      }
    }
  }
}



#placenames-medium::low-importance {
    /* Digne-les-Bains, Carpentras */
    [category = 2] {
      [zoom = 9][score >= 4000][isolation > 50000],
      [zoom = 10][isolation > 30000],
      [zoom = 11][isolation > 15000],
      [zoom = 12][isolation > 8000],
      [zoom >= 13] {
        text-name: "[name]";
        text-fill: @placenames;
        text-face-name: @sans;
        text-halo-fill: @city_halo;
        text-halo-radius: @standard-halo-radius * 1.5;
        text-dx: 0;
        text-dy: 0;
        // FIXME: https://github.com/mapnik/mapnik/commit/4eae86b7bc750a08a7ab103a780d6b4bf951e1b1
        // text-placements: "C,N,S,E,W,NW,NE,SE";
        text-placements: "N,S,E,SW,NW,NE,SE";
        text-placement-type: simple;

        [zoom >= 9][zoom < 13] {
          text-size: 12;
          text-wrap-width: @standard-wrap-width;
          text-line-spacing: -0.8;
          text-margin: 4.0;
          [dir = 1] {
            text-placements: 'N,S,E,W';
          }
        }
        [zoom >= 13][zoom < 16] {
            text-avoid-edges: false;
            [zoom >= 13] {
              text-size: 13;
              text-wrap-width: 65; // 5.0 em
              text-line-spacing: -0.65; // -0.05 em
              text-margin: 8.4; // 0.7 em
            }
            [zoom >= 14] {
              text-size: 15;
              text-wrap-width: 75; // 5.0 em
              text-line-spacing: -0.75; // -0.05 em
              text-margin: 10.5; // 0.7 em
            }
        }
      }
   }
}

#placenames-small::suburb {
  [place = 'suburb'][zoom >= 15][zoom < 17] {
    text-name: "[name]";
    text-size: 12;
    text-fill: @placenames-light;
    text-face-name: @sans;
    text-halo-fill: white;
    text-halo-radius: @standard-halo-radius;
    text-wrap-width: 70; // 5.0 em
    text-line-spacing: -0.70; // -0.05 em
    text-margin: 9.8; // 0.7 em
    text-placement-type: simple;
    // FIXME: https://github.com/mapnik/mapnik/commit/4eae86b7bc750a08a7ab103a780d6b4bf951e1b1
    // text-placements: "C,N,S,E,W,NW,NE,SE";
    text-placements: "N,S,E,W,NW,NE,SE";
    text-dx: 25;
    text-dy: 20;
    [zoom >= 16] {
      text-size: 14;
      text-wrap-width: 75; // 5.0 em
      text-line-spacing: -0.75; // -0.05 em
      text-margin: 10.5; // 0.7 em
    }
  }
}



#placenames-small::village {
  [place = 'village'] {

    [zoom >= 11]{

        [zoom = 11][population >= 8000],
        [zoom = 12][population >= 200],
        [zoom = 13] {

              text-dx: 0;
              text-dy: 0;
              // text-name: ' '+[name]+' '; // adding blanks seems to avoid troubles on tile boundary !
              text-name: [name];  // finally, simpler to add blanks inside the SQL request
              text-size: 10;
              text-fill: @placenames;
              text-face-name: @sans;
              text-halo-fill: @city_halo;
              text-halo-radius: @standard-halo-radius * 1.5;
              text-wrap-width: 45;
              text-line-spacing: -0.8;
              text-margin: 4.0;
              text-placement-type: simple;
              text-placements: "N,S,E,SW,NW,NE,SE";
        }

        [zoom >= 14][zoom < 17] {
          text-name: "[name]";
          text-size: 10;
          text-fill: @placenames;
          text-face-name: @sans;
          text-halo-fill: @other_halo;
          text-halo-radius: @standard-halo-radius * 1.5;
          text-wrap-width: 50; // 5.0 em
          text-line-spacing: -0.50; // -0.05 em
          text-margin: 5.0; // 0.7 em
          text-placement-type: simple;
          // FIXME: https://github.com/mapnik/mapnik/commit/4eae86b7bc750a08a7ab103a780d6b4bf951e1b1
          // text-placements: "C,N,S,E,W,NW,NE,SE";
          text-placements: "N,S,E,NW,NE,SE";
          text-avoid-edges: true;  // avoid troubles on tile border
          text-dx: 0;
          text-dy: 0;
          [zoom >= 13] {
            text-size: 11;
            text-wrap-width: 55; // 5.0 em
            text-line-spacing: -0.55; // -0.05 em
            text-margin: 5; // 0.7 em
          }
          [zoom >= 14] {
            text-fill: @placenames-light;
            text-halo-fill: white;
            text-size: 13;
            text-wrap-width: 65; // 5.0 em
            text-line-spacing: -0.65; // -0.05 em
            text-margin: 9.1; // 0.7 em
          }
          [zoom >= 15] {
            text-size: 14;
            text-wrap-width: 70; // 5.0 em
            text-line-spacing: -0.70; // -0.05 em
            text-margin: 9.8; // 0.7 em
          }
          [zoom >= 16] {
            text-size: 15;
            text-wrap-width: 75; // 5.0 em
            text-line-spacing: -0.75; // -0.05 em
            text-margin: 10.5; // 0.7 em
          }
        }

    }
  }
}

#placenames-small::quarter {
  [place = 'quarter'] {
    [zoom >= 16][zoom <= 17] {
      text-name: "[name]";
      text-fill: @placenames;
      text-face-name: @sans;
      text-halo-fill: @other_halo;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-halo-fill: white;
      text-fill: @placenames-light;
      text-wrap-width: 60; // 5.0 em
      text-line-spacing: -0.60; // -0.05 em
      text-margin: 8.4; // 0.7 em
      text-size: 12;
    }
  }
  [place = 'hamlet'] {
    [zoom >= 14][zoom < 18] {
      text-name: "[name]";
      text-fill: @placenames;
      text-face-name: @sans;
      text-halo-fill: white;
      text-halo-radius: @standard-halo-radius * 1.5;
      [zoom >= 14] {
        text-size: 10;
        text-wrap-width: 55; // 5.0 em
        text-line-spacing: -0.55; // -0.05 em
        text-margin: 7.7; // 0.7 em
      }
      [zoom >= 15] {
        text-size: 11;
        text-fill: @placenames-light;
        text-halo-fill: @other_halo;
        text-wrap-width: 45; // 4.5 em
        text-line-spacing: -0.8; // -0.08 em
        text-margin: 7.0; // 0.7 em
      }
      [zoom >= 16] {
        text-size: 12;
        text-wrap-width: 60; // 5.0 em
        text-line-spacing: -0.60; // -0.05 em
        text-margin: 8.4; // 0.7 em
        text-fill: @placenames-light;
        text-halo-fill: white;
      }
    }
  }
}

#placenames-small::neighborhood {
  [place = 'locality'],
  [place = 'neighbourhood'],
  [place = 'isolated_dwelling'],
  [place = 'farm'] {
    [zoom >= 15] {
      text-name: "[name]";
      text-size: 10;
      text-fill: @placenames;
      text-face-name: @sans;
      text-halo-fill: @other_halo;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-wrap-width: 45; // 4.5 em
      text-line-spacing: -0.8; // -0.08 em
      text-margin: 7.0; // 0.7 em
    }
    [zoom >= 16] {
      text-size: 12;
      text-wrap-width: 60; // 5.0 em
      text-line-spacing: -0.60; // -0.05 em
      text-margin: 8.4; // 0.7 em
      text-fill: @placenames-light;
      text-halo-fill: white;
    }
  }
  [place = 'square'] {
    [zoom >= 17] {
      text-name: "[name]";
      text-size: 11;
      text-face-name: @sans;
      text-wrap-width: 30; // 2.7 em
      text-line-spacing: -1.7; // -0.15 em
    }
  }
}
