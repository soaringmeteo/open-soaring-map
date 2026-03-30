-- Compute peak isolations: for each peak/volcano, find the distance to the nearest
-- peak/volcano with equal or greater elevation.
-- Uses a LATERAL join with the <-> KNN operator for GiST index-assisted distance-ordered
-- scanning; ST_DistanceSphere gives accurate spherical distances (metres) independent of
-- Web Mercator latitude distortion.
-- Based on https://github.com/MathiasGroebe/discrete_isolation by Mathias Groebe
WITH peaks AS (
  SELECT osm_id, way,
    ele::NUMERIC AS ele_value
  FROM planet_osm_point
  WHERE "natural" IN ('peak', 'volcano')
    AND ele ~ '^-?[0-9]+(\.[0-9]+)?$'
)
UPDATE planet_osm_point outer_point
SET otm_isolation = round(COALESCE(nearest.dist, 100000))::TEXT
FROM peaks a
LEFT JOIN LATERAL (
  SELECT ST_DistanceSphere(ST_Transform(a.way, 4326), ST_Transform(b.way, 4326)) AS dist
  FROM peaks b
  WHERE b.ele_value >= a.ele_value
    AND b.osm_id != a.osm_id
  ORDER BY a.way <-> b.way
  LIMIT 1
) nearest ON TRUE
WHERE a.osm_id = outer_point.osm_id
  AND outer_point."natural" IN ('peak', 'volcano');

