SELECT
  track_name,
  artist_name,
  AVG(danceability_pct) AS avg_danceability,
  AVG(energy_pct) AS avg_energy
FROM
  {{ source("raw_ingestion", "spotify_top_2023_metadata") }}
GROUP BY
  track_name,
  artist_name
ORDER BY
  AVG(danceability_pct) DESC
LIMIT
  25