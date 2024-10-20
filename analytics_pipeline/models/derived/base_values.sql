WITH
  clean_sensor_data AS (
    -- Clean and standardize the raw data
  SELECT
    DISTINCT CAST(time AS TIMESTAMP) AS observation_time,
    CAST(value AS FLOAT64) AS value,
    TRIM(CAST(field AS STRING)) AS field,
    TRIM(CAST(robot_id AS STRING)) AS robot_id,
    CAST(CAST(run_uuid AS NUMERIC) AS STRING) AS run_uuid,
    TRIM(CAST(sensor_type AS STRING)) AS sensor_type,
    TO_HEX(SHA256(TO_JSON_STRING(STRUCT(time,
            value,
            field,
            robot_id,
            sensor_type,
            run_uuid)))) AS raw_record_hash_code,
    CURRENT_TIMESTAMP AS etl_update_ts
  FROM
    `storied-storm-353916.raw_sensor_data.sensor_data` ),
  unified_timestamps AS (
    -- Get a union of all timestamps from all sensors and both robots
  SELECT
    DISTINCT observation_time
  FROM
    clean_sensor_data ),
  convert_to_features AS (
    -- Pivot the data into features and align timestamps
  SELECT
    ut.observation_time,
    MAX(CASE
        WHEN sd.field = 'fx' AND sd.robot_id = '1' THEN sd.value
    END
      ) AS fx_1,
    MAX(CASE
        WHEN sd.field = 'fx' AND sd.robot_id = '2' THEN sd.value
    END
      ) AS fx_2,
    MAX(CASE
        WHEN sd.field = 'fy' AND sd.robot_id = '1' THEN sd.value
    END
      ) AS fy_1,
    MAX(CASE
        WHEN sd.field = 'fy' AND sd.robot_id = '2' THEN sd.value
    END
      ) AS fy_2,
    MAX(CASE
        WHEN sd.field = 'fz' AND sd.robot_id = '1' THEN sd.value
    END
      ) AS fz_1,
    MAX(CASE
        WHEN sd.field = 'fz' AND sd.robot_id = '2' THEN sd.value
    END
      ) AS fz_2,
    MAX(CASE
        WHEN sd.field = 'x' AND sd.robot_id = '1' THEN sd.value
    END
      ) AS x_1,
    MAX(CASE
        WHEN sd.field = 'x' AND sd.robot_id = '2' THEN sd.value
    END
      ) AS x_2,
    MAX(CASE
        WHEN sd.field = 'y' AND sd.robot_id = '1' THEN sd.value
    END
      ) AS y_1,
    MAX(CASE
        WHEN sd.field = 'y' AND sd.robot_id = '2' THEN sd.value
    END
      ) AS y_2,
    MAX(CASE
        WHEN sd.field = 'z' AND sd.robot_id = '1' THEN sd.value
    END
      ) AS z_1,
    MAX(CASE
        WHEN sd.field = 'z' AND sd.robot_id = '2' THEN sd.value
    END
      ) AS z_2
  FROM
    unified_timestamps ut
  LEFT JOIN
    clean_sensor_data sd
  ON
    ut.observation_time = sd.observation_time
  GROUP BY
    ut.observation_time ),
  interpolate_features AS (
    -- Interpolate missing values for each column (linear interpolation)
  SELECT
    observation_time,
    COALESCE(fx_1, LAG(fx_1) OVER (ORDER BY observation_time) + (LEAD(fx_1) OVER (ORDER BY observation_time) - LAG(fx_1) OVER (ORDER BY observation_time)) / 2) AS fx_1,
    COALESCE(fx_2, LAG(fx_2) OVER (ORDER BY observation_time) + (LEAD(fx_2) OVER (ORDER BY observation_time) - LAG(fx_2) OVER (ORDER BY observation_time)) / 2) AS fx_2,
    COALESCE(fy_1, LAG(fy_1) OVER (ORDER BY observation_time) + (LEAD(fy_1) OVER (ORDER BY observation_time) - LAG(fy_1) OVER (ORDER BY observation_time)) / 2) AS fy_1,
    COALESCE(fy_2, LAG(fy_2) OVER (ORDER BY observation_time) + (LEAD(fy_2) OVER (ORDER BY observation_time) - LAG(fy_2) OVER (ORDER BY observation_time)) / 2) AS fy_2,
    COALESCE(fz_1, LAG(fz_1) OVER (ORDER BY observation_time) + (LEAD(fz_1) OVER (ORDER BY observation_time) - LAG(fz_1) OVER (ORDER BY observation_time)) / 2) AS fz_1,
    COALESCE(fz_2, LAG(fz_2) OVER (ORDER BY observation_time) + (LEAD(fz_2) OVER (ORDER BY observation_time) - LAG(fz_2) OVER (ORDER BY observation_time)) / 2) AS fz_2,
    COALESCE(x_1, LAG(x_1) OVER (ORDER BY observation_time) + (LEAD(x_1) OVER (ORDER BY observation_time) - LAG(x_1) OVER (ORDER BY observation_time)) / 2) AS x_1,
    COALESCE(x_2, LAG(x_2) OVER (ORDER BY observation_time) + (LEAD(x_2) OVER (ORDER BY observation_time) - LAG(x_2) OVER (ORDER BY observation_time)) / 2) AS x_2,
    COALESCE(y_1, LAG(y_1) OVER (ORDER BY observation_time) + (LEAD(y_1) OVER (ORDER BY observation_time) - LAG(y_1) OVER (ORDER BY observation_time)) / 2) AS y_1,
    COALESCE(y_2, LAG(y_2) OVER (ORDER BY observation_time) + (LEAD(y_2) OVER (ORDER BY observation_time) - LAG(y_2) OVER (ORDER BY observation_time)) / 2) AS y_2,
    COALESCE(z_1, LAG(z_1) OVER (ORDER BY observation_time) + (LEAD(z_1) OVER (ORDER BY observation_time) - LAG(z_1) OVER (ORDER BY observation_time)) / 2) AS z_1,
    COALESCE(z_2, LAG(z_2) OVER (ORDER BY observation_time) + (LEAD(z_2) OVER (ORDER BY observation_time) - LAG(z_2) OVER (ORDER BY observation_time)) / 2) AS z_2
  FROM
    convert_to_features )
  -- Final Select Statement to return the features with interpolated values
SELECT
  *
FROM
  interpolate_features
ORDER BY
  observation_time