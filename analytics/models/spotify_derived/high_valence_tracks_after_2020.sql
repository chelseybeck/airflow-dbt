SELECT
  track_name,
  artist_name,
  released_year,
  valence_pct,
  streams
FROM
  {{ source("raw_ingestion", "spotify_top_2023_metadata") }}
WHERE
  released_year > 2020
  AND valence_pct > 70
ORDER BY
  valence_pct DESC,
  track_name,
  artist_name DESC