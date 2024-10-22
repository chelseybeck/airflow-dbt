SELECT
  artist_name,
  SUM(streams) AS total_streams
FROM
  {{ source("raw_ingestion", "spotify_top_2023_metadata") }}
GROUP BY
  artist_name
ORDER BY
  total_streams DESC
LIMIT
  10