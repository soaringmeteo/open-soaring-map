// ==================================================================
//                    ROAD & RAIL LINES
// ==================================================================



// draw perpendicular dash for railway
#roads_low[zoom>=7][zoom<=8][type='railway']::rail_perpendicular,
#roads_med[zoom>=9][zoom<=10][type='railway']::rail_perpendicular {
    /* background: to avoid weird pattern when many tracks are overlapping */
    background/line-color: @land;
    background/line-width: 4;

    line-color: @rail-line;
    line-cap: butt;
    line-dasharray: 0,4,1,4; /* start with space to avoid dense pattern on very short ways */
    line-width: 4;

}

// low level : only motorway/trunk/railway
#roads_low{

  line-width: [roadsize];
  line-color: @standard-fill;
  [type='railway'] { line-color: @rail-line;}
}

// At mid-level scales start to show primary  routes
#roads_med{
  line-color: @standard-fill;

  [type='railway'] {
    line-color: @rail-line;
  }

  line-width: [roadsize];

}

// At higher levels the roads become more complex. We're now showing
//more than just automobile and railway routes - footways, and cycleways
//come in as well.

// ----------------------------------------------------------
// ---------------- Variables -------------------------------
// ----------------------------------------------------------
//
// * Road width variables that are used in road & bridge styles.
// *
// * Roads are drawn in two steps. First, a line if the width of the road + the
// * two borders is drawn and then a line of the width of the road is drawn on
// * top, to make a road with borders. Here, the width of the ways is the width
// * of the fill of the road and the border width is the width of a single
// * border, on one side (first line is drawn with a width of way with + 2 *
// * border_width).



// ---- Rail background with hatches -------------------------

#roads_high[zoom>=11][tunnel='no']
{
    [type='railway']::rail_perpendicular {
      [service!='minor'],
      [service='minor'][zoom>=13]
      {
        line-cap: butt;
        line-color: @rail-line;
        [service='minor'] {
          line-color: lighten(@rail-line, 25%);
        }

        /* hatches: start with space to avoid dense pattern on very short ways */
        line-dasharray: 0,2,1,2;
        [zoom>=14] { line-dasharray: 0,4,1,4; }

        line-width: 3;
        [zoom>=19] { line-width: 6; }
      }
    }
}

// ---- Casing for roads -----------------------------------------------

// Line to draw both borders (left and right)
#roads_high::outline {

  [type='motorway'],[type='motorway_link']
  ,[type='primary'] ,[type='primary_link']
  ,[type='secondary'] ,[type='secondary_link']
  ,[type='tertiary'] ,[type='tertiary_link']
  ,[type='unclassified'],[type='residential'] 
  ,[type='living_street'],[type='pedestrian']
  ,[type='service'][service!='minor'] 
  {

    line-cap: round;
    line-join: round;

    [tunnel!='no'],[bridge!='no'] {  line-cap: butt;    }
    [tunnel!='no']                {  line-dasharray: 3,3; }  // dashed line for tunnel
    
    line-width: [roadsize] + 2*[roadcase];
    [type='service'][service='minor'] {  line-width: 0.5*[roadsize] + [roadcase]; } // size divided by 2

    line-color: @standard-case; 
  }
}

// no casing for track...cycleway,path  excepted when tunnel or bridge  when high zoom
#roads_high::outlineline[zoom>=16] {
    [type='track'],[type='bridleway'],[type='footway'],[type='cycleway'],[type='path']{
        [tunnel!='no'],[bridge!='no'] {

            line-color: @bridge_case;
            [type='cycleway'],[type='path'][can_bicycle='designated'] {  line-color: @bridge_path_case; }
            line-cap: butt;
            line-join: round;
            line-dasharray: 3,3;
            line-width: [roadsize] + 2*[roadcase];

            // enlarge size for cycleway
            [type='cycleway'][oneway='no'][oneway_bicycle='no'] { line-width: 1.5*[roadsize]  + 2*[roadcase]; }  
        }
    }
}

// stuff for segregated cycleway on path
#roads_high::path_outline_right[zoom>=17][type='path'][can_bicycle='designated'][segregated='yes'],
{
  line-cap: butt;
  line-color: @path-fill;

  line-width: [roadsize];
  line-offset: [roadsize]/2 + [sizecycle]/2;
  [oneway='no'][oneway_bicycle='no'] {
    line-width: [roadsize]; 
    line-offset: [roadsize]/2 + [sizecycle]*1.5/2;
  }


}

//===========================================================================
// roads inner  color
//
// remind that view cyclosm_ways combines motorway/trunk
//===========================================================================
#roads_high::inline {

    [type='motorway'],[type='motorway_link'],
    [type='primary'],[type='primary_link'],
    [type='secondary'],[type='secondary_link'],
    [type='tertiary'],[type='tertiary_link'],
    [type='unclassified'],
    [type='residential'],
    [type='service'][service!='minor'],
    [type='service'][service='minor'][zoom>=15],
    [type='living_street'],
    [type='pedestrian'],
    [type='steps']        

    {
     
        // tunnel : put a white background , and set a small opacity to draw the road with a very light color
        [tunnel!='no']{
            b/line-width: [roadsize];
            b/line-color: white;
            line-opacity: 0.1;
        }
     
        line-cap: round;
        line-join: round;
        line-width: [roadsize];
        [type='service'][service='minor'] { line-width: 0.5*[roadsize] ;}

        line-color: @standard-fill;

        // dash line for steps
        [type='steps'] {
            line-cap: butt;
            line-dasharray: 0.5,0.5;
            [zoom>=16] { line-dasharray: 1.5,0.75; }
            [zoom>=17] {  line-dasharray: 2,1; }

        }

  }
}


#roads_high::inline {
    [type='track'],[type='bridleway'],[type='footway'],[type='cycleway']{

      // different type of dash, depending on surface . 
      // If can_bicycle=no then small points ( do not use a specific color for this, because now we take hiking in consideration )


      
      
      // tunnel : set a white background and a small opacity to draw the road with a very light color
      [tunnel!='no']{ 
            background/line-join: round;
            background/line-opacity: 0.4;
            background/line-color: #FFFFFF;
            background/line-width: [roadsize];
      }

      line-cap: butt;
      line-join: round;
      line-width: [roadsize];
      line-color: @standard-fill;
  }
}

// if path compatible bike ( 'alpine'='no' and can_bicycle != no ) 
//   take color mixed-cycle-fill , and make difference between road/cyclocross/mtb+unknown
// otherwise take color path-fill and make difference alpine='no' / alpine='low' / 'alpine='medium'/alpine='high' 
#roads_high::inline {
  [type='path']
  {


      
      // tunnel : set a small opacity to draw the road with a  light color
      // since there is no casing, we put middle opacity
      [tunnel!='no']{  
        background/line-join: round;
        background/line-color: #FFFFFF;
        background/line-width: [roadsize];
        line-opacity: 0.5; 
      }

    line-cap: butt;
    line-join: round;

    line-width: [roadsize];

    // too difficult or not bike compatible => pink color
    line-color: @standard-fill;
    [alpine='low'] { line-dasharray: 24,2; }
    [alpine='medium'] { line-dasharray: 12,4; }
    [alpine='high'] { line-dasharray: 4,4; }
    [alpine='veryhigh'] { line-dasharray: 1,4; }
  }
}




/*
//------------------------------------------------------
//skip details for MountainBike difficulty
//------------------------------------------------------
#roads_high::mtbscale[mtb_scale>=0][zoom>=15]
{
  [type='service'],
  [type='track'],
  [type='bridleway'],
  [type='footway'],
  [type='path'],
  [type='cycleway']
  {
    line-color: #2076ff;
    line-dasharray: 1,8;

    [mtb_scale=1] {
      line-dasharray: 1,1,1,8;
    }
    [mtb_scale>=2] {
      line-color: #FF0000;
    }
    [mtb_scale>=3] {
      line-color: #000000; //one dash |
    }
    [mtb_scale>=4] {
      line-dasharray: 1,1,1,8;// 2 dashes ||
    }
    [mtb_scale>=5] {
      line-dasharray: 1,1,1,1,1,8;// 3 dashes |||
    }
    [mtb_scale>=6] {
      line-dasharray: 1,1,1,1,1,1,1,8;// 4 dashes ||||
    }

    line-width: [roadsize]*2;

  }
}

#roads_high::mtbscale[mtb_scale=null][mtb_scale_imba>=0][zoom>=15]
{
  [type='service'],
  [type='track'],
  [type='bridleway'],
  [type='footway'],
  [type='path'],
  [type='cycleway']
  {
    line-cap: round;
    line-color: #FFFFFF;
    line-dasharray: 0.1,12;

    [mtb_scale_imba>=1] {
      line-color: #4e9b00;
    }
    [mtb_scale_imba>=2] {
      line-color: #2076ff;
    }
    [mtb_scale_imba>=3] {
      line-color: #000000;
    }
    [mtb_scale_imba>=4] {
      line-color: #000000;
      line-dasharray: 0.1,4,0.1,18;
    }

    line-width: [roadsize]*2;

    [zoom>=17] {
      line-dasharray: 0.1,24;
      [mtb_scale_imba>=4] {
        line-dasharray: 0.1,4,0.1,36;
      }
    }

  }
}

-------------------------------------
*/

// railway line
#roads_high::rail_line[zoom>=11],
{
    [type='railway'][tunnel='no'] {
        [service!='minor'],
        [service='minor'][zoom>=13]
        {

            line-color: @rail-line;
            [service='minor'] {
                line-color: lighten(@rail-line, 25%);
            }

        line-width: [roadsize];

        }
    }
}


// ---- Turning Circles ---------------------------------------------

// CAUTION: for turning_circle , the roadcase value for turning_circle must be identical to the roadcase value of 'residential'
// because original Cyclosm was using the 'residential' casing value for 'turning_circle' casing
// I do not know the impact if we change this
#turning_circle_case[zoom>=14] {
  marker-fill: @standard-fill;
  marker-line-color: @standard-case;
  marker-line-width: 2* [roadcase];
  marker-allow-overlap: true;
  marker-width: [roadsize];
}

#turning_circle_fill[zoom>=14] {
  marker-fill: @standard-fill;
  marker-line-width: 0;
  marker-line-opacity: 0;
  marker-allow-overlap: true;
  marker-width: [roadsize];
}


// ==================================================================
// AEROWAYS
// ==================================================================

#aeroway[zoom>=11] {
    line-color: @aeroway;
    line-width: [roadsize];
}

// ==================================================================
// BICYCLE ROUTES
// ==================================================================

/*---------------- skip this part than changes the color of standard highways

#bicycle_routes_gen0[zoom >= 2] {
  opacity: 0.75;

  line-color: @icn-overlay;
  [route='mtb'] {
    line-color: @mtb-overlay;
  }

  line-width: 1;
}
#bicycle_routes_gen1[zoom >= 5] {
  opacity: 0.75;
  line-color: @icn-overlay;
  line-width: 1;

  [type='ncn'] {
    line-color: @ncn-overlay;
    [zoom >= 5] { line-width: 0.5; }
    [zoom >= 7] { line-width: 1; }
  }
  [route='mtb'] {
    line-color: @mtb-overlay;
  }

  [state='proposed'] {
    line-dasharray: 6,6;
  }
}
#bicycle_routes_gen2[zoom >= 8] {
  opacity: 0.6;
  line-color: @icn-overlay;
  [type='ncn'] {
    line-color: @ncn-overlay;
  }
  [type='rcn'] {
    line-color: @rcn-overlay;
  }
  [route='mtb'] {
    line-color: @mtb-overlay;
  }

  [state='proposed'] {
    line-dasharray: 6,6;
  }

  line-width: 1;
  [zoom >= 9] { line-width: 1.5; }
  [zoom >= 10] { line-width: 2; }
}

*/



