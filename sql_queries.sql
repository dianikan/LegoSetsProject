-- How many LEGO sets have been released since 1970? Is there a noticable trend?
-- Is there a relationship between the price of a set and its number of pieces?
-- Which has been the most popular theme in each decade?
-- Are LEGO minifigures most closely tied to licensed sets?
-- How many LEGO sets have been released since 1970? Is there a noticable trend?
use lego_sets;
select count(distinct set_id) from lego_sets; 
select  count(*) as lego_set,year from lego_sets group by year order by year;


--- Is there a relationship between the price of a set and its number of pieces?

WITH PriceRanges AS (
    SELECT
        CASE
            WHEN us_retailprice < 10 THEN 'Under $10'
            WHEN us_retailprice >= 10 AND us_retailprice < 25 THEN '$10 - $25'
            WHEN us_retailprice >= 25 AND us_retailprice < 50 THEN '$25 - $50'
            WHEN us_retailprice >= 50 AND us_retailprice < 100 THEN '$50 - $100'
            WHEN us_retailprice >= 100 AND us_retailprice < 200 THEN '$100 - $200'
            ELSE 'Over $200'
        END AS price_range,
        pieces
    FROM lego_sets
    WHERE us_retailprice IS NOT NULL AND pieces IS NOT NULL
)
SELECT
    price_range,
    ROUND(AVG(pieces)) AS average_pieces
FROM PriceRanges
GROUP BY price_range
ORDER BY
    CASE
        WHEN price_range = 'Under $10' THEN 1
        WHEN price_range = '$10 - $25' THEN 2
        WHEN price_range = '$25 - $50' THEN 3
        WHEN price_range = '$50 - $100' THEN 4
        WHEN price_range = '$100 - $200' THEN 5
        ELSE 6
    END;

-- Which has been the most popular theme in each decade?


 WITH RankedThemes AS (
    SELECT
        FLOOR(year / 10) * 10 AS decade,
        theme,
        COUNT(*) AS theme_count,
        RANK() OVER (PARTITION BY FLOOR(year / 10) * 10 ORDER BY COUNT(*) DESC) AS rank_num
    FROM lego_sets
    WHERE year IS NOT NULL AND theme IS NOT NULL -- Added theme null check
    GROUP BY decade, theme
)
SELECT
    decade,
    theme,
    theme_count
FROM RankedThemes
WHERE rank_num = 1
ORDER BY decade;

-- Are LEGO minifigures most closely tied to licensed sets?

with a as (select minifigs, themeGroup,count(*) from lego_sets group by themeGroup, minifigs)
select RANK() OVER (PARTITION BY minifigs ORDER BY themeGroup,COUNT(*) DESC) AS rank_num from a;
SELECT
    CASE
        WHEN themeGroup IS NOT NULL AND themeGroup = 'licensed' THEN 'Licensed'
        ELSE 'Non-Licensed'
    END AS set_type,
    AVG(minifigs) AS average_minifigs
FROM lego_sets
WHERE minifigs IS NOT NULL
GROUP BY set_type;

-- Get the specific themes that came back and the years they were reintroduced
WITH ThemeProductionPeriods AS (
    SELECT
        theme,
        year,
        MIN(year) OVER (PARTITION BY theme) AS first_year
    FROM
        lego_sets
),
ThemeGaps AS (
    SELECT
        theme,
        year,
        LAG(year, 1, year - 1) OVER (PARTITION BY theme ORDER BY year) AS prev_year,
        first_year
    FROM
        ThemeProductionPeriods
),
ReintroducedThemes AS (
    SELECT
        theme,
        year AS reintroduction_year,
        prev_year,
        first_year
    FROM
        ThemeGaps
    WHERE
        year - prev_year > 1
)
SELECT
    theme,
    reintroduction_year,
    first_year,
    prev_year AS last_year_before_reintroduction
FROM
    ReintroducedThemes
ORDER BY
    theme,
    reintroduction_year;
