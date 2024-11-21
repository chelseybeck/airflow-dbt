select
    track_name,
    artist_name,
    AVG(danceability_pct) as avg_danceability,
    AVG(energy_pct) as avg_energy
from
    {{ source("spotify_raw", "spotify_top_2023_metadata") }}
group by
    track_name,
    artist_name
order by
    AVG(danceability_pct) desc
limit
    25
