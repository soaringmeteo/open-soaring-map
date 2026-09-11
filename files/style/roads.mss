// ==================================================================
//                    ROAD & RAIL LINES
// ==================================================================


// At mid-level scales (zoom 10-11-12) start to show primary  routes
#roads_med::outline[type != 'railway'] {
  line-cap: round;
  line-join: round;
  line-color: @standard-case;
  line-width: [roadsize] + 1;

  [tunnel!='no'] { line-dasharray: 5,4; }
}
#roads_med::inline {
  [type != 'railway'],[type = 'railway'][tunnel = 'no'] {
      line-cap: round;
      line-join: round;
      line-color: @standard-fill;
      [type='railway'] {
        line-color: @rail-line;
      }
      line-width: [roadsize];
  }
}

// At higher levels (zoom 13+) the roads become more complex. We're now showing
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


// railway line
#roads_high::rail_line[zoom>=13],
{
  [type='railway'][tunnel='no'][service!='minor'] {
    line-color: @rail-line;
    line-width: [roadsize];
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
  ,[type='service'][service!='minor']
  {

    line-cap: round;
    line-join: round;

    [tunnel!='no'],[bridge!='no'] {  line-cap: butt;    }
    [tunnel!='no']                {  line-dasharray: 5,4; }  // dashed line for tunnel

    line-width: 0.8*[roadsize] + [roadcase];
    [type='service'][service='minor'] {  line-width: 0.4*[roadsize] + 0.5*[roadcase]; } // size divided by 2

    line-color: @standard-case;
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
    [type='service'][service='minor'][zoom>=15]

    {
     
        // tunnel : put a white background , and set a small opacity to draw the road with a very light color
        [tunnel!='no']{
            b/line-width: 0.5*[roadsize];
            b/line-color: white;
            line-opacity: 0.1;
        }
     
        line-cap: round;
        line-join: round;
        line-width: 0.8*[roadsize];
        [type='service'][service='minor'] { line-width: 0.4*[roadsize] ;}

        line-color: @standard-fill;

  }
}


#roads_high::inline {
    [type='footway'],[type='cycleway']{

      // different type of dash, depending on surface . 
      // If can_bicycle=no then small points ( do not use a specific color for this, because now we take hiking in consideration )


      
      
      // tunnel : set a white background and a small opacity to draw the road with a very light color
      [tunnel!='no']{ 
            background/line-join: round;
            background/line-opacity: 0.4;
            background/line-color: #FFFFFF;
            background/line-width: 0.5*[roadsize];
      }

      line-cap: butt;
      line-join: round;
      line-width: 0.5*[roadsize];
      line-color: @standard-fill;
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
  marker-width: 0.5*[roadsize];
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
