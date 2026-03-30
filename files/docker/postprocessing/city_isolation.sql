-- Compute city isolations: for each city/town/village, find the distance to the nearest
-- city/town/village with equal or greater weighted population.
-- Uses a LATERAL join with the <-> KNN operator for GiST index-assisted distance-ordered
-- scanning; ST_DistanceSphere gives accurate spherical distances (metres) independent of
-- Web Mercator latitude distortion.
-- Based on https://github.com/MathiasGroebe/discrete_isolation by Mathias Groebe
WITH cities_with_pop AS (
  SELECT osm_id, way,
    CASE
      WHEN (population ~ '^[0-9]{1,8}$') THEN population::INTEGER * (CASE WHEN place = 'city' THEN 1.5 WHEN place = 'town' THEN 1.25 ELSE 1 END)
      WHEN (place = 'city') THEN 100000 * 1.5
      WHEN (place = 'town') THEN 1000 * 1.25
      WHEN (place = 'village') THEN 100
    END AS pop_value
  FROM planet_osm_point
  WHERE place IN ('city', 'town', 'village')
)
UPDATE planet_osm_point outer_point
SET otm_isolation = round(COALESCE(nearest.dist, 30000000))
FROM cities_with_pop a
LEFT JOIN LATERAL (
  SELECT ST_DistanceSphere(ST_Transform(a.way, 4326), ST_Transform(b.way, 4326)) AS dist
  FROM cities_with_pop b
  WHERE b.pop_value >= a.pop_value
    AND b.osm_id != a.osm_id
  ORDER BY a.way <-> b.way
  LIMIT 1
) nearest ON TRUE
WHERE a.osm_id = outer_point.osm_id
  AND outer_point.place IN ('city', 'town', 'village');
