{{ config(materialized='table')}}

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart='day',
        start_date="cast('2016-01-01' AS DATE)",
        end_date="CAST('2019-01-01' AS DATE)"
    )}}
)

SELECT
    CAST(date_day AS DATE)              AS date_key,
    EXTRACT(YEAR FROM date_day)         AS year_number,
    EXTRACT(QUARTER FROM date_day)      AS quarter_number,
    EXTRACT(MONTH FROM date_day)        AS month_number,
    EXTRACT(DAY FROM date_day)          AS day_of_month,
    EXTRACT(DAYOFWEEK FROM date_day)    AS day_of_week,
    DATE_TRUNC('month', date_day)       AS month_start_date,
    DATE_TRUNC('quarter', date_day)     AS quarter_start_date,
    CASE
        WHEN date_day >= CAST('2017-01-01' AS DATE)
        AND date_day < CAST('2018-09-01' AS DATE)
        THEN TRUE
        ELSE FALSE
    END AS is_core_analysis_period
FROM date_spine