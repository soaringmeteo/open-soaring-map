-- Compute city isolations: for each city/town, find the distance to the nearest
-- city/town with equal or greater population.
-- Initially based on https://github.com/MathiasGroebe/discrete_isolation by Mathias Groebe
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
SET otm_isolation = round(
  COALESCE(
    (
      SELECT ST_Distance(outer_city.way, inner_city.way) distance
      FROM cities_with_pop outer_city, cities_with_pop inner_city
      WHERE outer_city.osm_id = outer_point.osm_id
        AND inner_city.pop_value >= outer_city.pop_value
        AND inner_city.osm_id != outer_city.osm_id
      ORDER BY distance
      LIMIT 1
    ),
    30000000
  )
)
WHERE place IN ('city', 'town', 'village');
