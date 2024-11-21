select
    artist_name,
    SUM(streams) as total_streams
from
    {{ source("spotify_raw", "spotify_top_2023_metadata") }}
group by
    artist_name
order by
    total_streams desc
limit
    10
