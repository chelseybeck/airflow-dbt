select
    track_name,
    artist_name,
    released_year,
    valence_pct,
    streams
from
    {{ source("raw_ingestion", "spotify_top_2023_metadata") }}
where
    released_year > 2020
    and valence_pct > 70
group by
    track_name,
    artist_name,
    released_year,
    valence_pct,
    streams
order by
    valence_pct desc,
    track_name asc,
    artist_name desc
