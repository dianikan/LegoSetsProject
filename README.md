# LEGO Sets Analysis

This project explores a dataset of LEGO sets, analyzing various aspects of LEGO's production history and trends. The analysis focuses on answering key questions about LEGO sets released since 1970.

## Project Goals

The primary goals of this project are to:

* Determine the total number of LEGO sets released since 1970 and identify any noticeable trends in production.
* Investigate the relationship between the price of a LEGO set and its number of pieces.
* Identify the most popular LEGO theme in each decade.
* Examine the correlation between LEGO minifigures and licensed sets.
* Identify LEGO themes that have been reintroduced after a period of discontinuation.

## Dataset

The dataset used in this analysis contains information about LEGO sets, including:

* `set_id`
* `name`
* `year`
* `theme`
* `subtheme`
* `themeGroup`
* `category`
* `pieces`
* `minifigs`
* `agerange_min`
* `US_retailPrice`
* `bricksetURL`
* `thumbnailURL`
* `imageURL`

## Analysis and Queries

### 1.How many LEGO sets have been released since 1970? Is there a noticeable trend?

```sql
use lego_sets;
select count(distinct set_id) from lego_sets;
select count(*) as lego_set, year from lego_sets group by year order by year;
```
The total number of unique LEGO sets released since 1970 is 18457. The yearly count, as shown in the table and graph below, reveals a clear upward trend, particularly in the 21st century, indicating a significant increase in LEGO set production. This could be attributed to factors like the growing popularity of LEGO, expansion into new markets, and diversification of product lines.

This table provides a detailed breakdown of the number of sets released each year, further supporting the observed upward trend.

| Lego Set Count | Year |
|---|---|
| 41  | 1970 |
| 78  | 1971 |
| 45  | 1972 |
| 76  | 1973 |
| 40  | 1974 |
| 45  | 1975 |
| 76  | 1976 |
| 74  | 1977 |
| 87  | 1978 |
| 90  | 1979 |
| 117 | 1980 |
| 74  | 1981 |
| 73  | 1982 |
| 76  | 1983 |
| 84  | 1984 |
| 141 | 1985 |
| 152 | 1986 |
| 200 | 1987 |
| 79  | 1988 |
| 146 | 1989 |
| 129 | 1990 |
| 147 | 1991 |
| 112 | 1992 |
| 168 | 1993 |
| 154 | 1994 |
| 172 | 1995 |
| 213 | 1996 |
| 264 | 1997 |
| 383 | 1998 |
| 352 | 1999 |
| 384 | 2000 |
| 409 | 2001 |
| 449 | 2002 |
| 426 | 2003 |
| 419 | 2004 |
| 395 | 2005 |
| 467 | 2006 |
| 449 | 2007 |
| 443 | 2008 |
| 487 | 2009 |
| 529 | 2010 |
| 591 | 2011 |
| 703 | 2012 |
| 710 | 2013 |
| 757 | 2014 |
| 808 | 2015 |
| 845 | 2016 |
| 861 | 2017 |
| 829 | 2018 |
| 848 | 2019 |
| 849 | 2020 |
| 944 | 2021 |
| 967 | 2022 |



### 2. Is there a relationship between the price of a set and its number of pieces?

```sql
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
    ```
The table shows a clear link between price and LEGO set size: higher price generally means more pieces. TThis likely means bigger, more complex sets cost more. It might also mean smaller sets have a higher price per piece.

| Price Range   | Average Pieces |
|---------------|----------------|
| Under $10     | 60             |
| $10 - $25     | 138            |
| $25 - $50     | 325            |
| $50 - $100    | 697            |
| $100 - $200   | 1458           |
| Over $200     | 3287           |



    
### 3.Which has been the most popular theme in each decade?

```sql
WITH RankedThemes AS (
    SELECT
        FLOOR(year / 10) * 10 AS decade,
        theme,
        COUNT(*) AS theme_count,
        RANK() OVER (PARTITION BY FLOOR(year / 10) * 10 ORDER BY COUNT(*) DESC) AS rank_num
    FROM lego_sets
    WHERE year IS NOT NULL AND theme IS NOT NULL 
    GROUP BY decade, theme
)
SELECT
    decade,
    theme,
    theme_count
FROM RankedThemes
WHERE rank_num = 1
ORDER BY decade;
```

| Decade | Theme      | Theme Count |
|--------|------------|-------------|
| 1970   | LEGOLAND   | 159         |
| 1980   | Town       | 190         |
| 1990   | Town       | 346         |
| 2000   | Gear       | 892         |
| 2010   | Gear       | 1306        |
| 2020   | Gear       | 585         |

It's clear that "Gear" has been the dominant theme in recent decades (2000, 2010, and 2020). The dominance of the 'Gear' theme suggests a shift in LEGO's product strategy towards more technical or mechanical sets in the 21st century. "Town" was popular in the 80s and 90s, which reflects the classic LEGO building experience, focusing on city-themed sets.


### 4.Are LEGO minifigures most closely tied to licensed sets?
```sql
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
```
'Non-Licensed', '1.0295961876097317'
'Licensed', '2.3722598644878437'

Licensed LEGO sets have more minifigures on average than non-licensed ones. This is likely because licensed sets often feature popular characters that people want to collect.

### 5.Get the specific themes that came back and the years they were reintroduced
```sql 
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
```

This data shows LEGO themes that were reintroduced after a gap in production.  "Books" and "Gear" themes were reintroduced the most. Some themes like "Castle" and "Space" were brought back after long gaps. This information could help understand how LEGO keeps older themes fresh and interesting for new generations
| Theme                 | Reintroduction Year | Previous Year | First Year |
|----------------------|---------------------|---------------|------------|
| Advanced models       | 2006                | 2004          | 2000       |
| Adventurers           | 2003                | 2000          | 1998       |
| Assorted              | 1999                | 1996          | 1989       |
| Baby                  | 2004                | 2001          | 2000       |
| Basic                 | 1976                | 1974          | 1972       |
| Basic                 | 1980                | 1978          | 1972       |
| Bionicle              | 2014                | 2010          | 2001       |
| Boats                 | 1987                | 1982          | 1982       |
| Boats                 | 1991                | 1987          | 1982       |
| Boats                 | 1996                | 1991          | 1982       |
| Books                 | 1975                | 1973          | 1970       |
| Books                 | 1977                | 1975          | 1970       |
| Books                 | 1980                | 1977          | 1970       |
| Books                 | 1984                | 1982          | 1970       |
| Books                 | 1987                | 1985          | 1970       |
| Books                 | 2007                | 2005          | 1970       |
| Bricklink             | 2021                | 2019          | 2019       |
| Bricks and More       | 2008                | 2006          | 2006       |
| Bulk Bricks           | 2006                | 2004          | 2000       |
| Castle                | 1981                | 1979          | 1978       |
| Castle                | 1983                | 1981          | 1978       |
| Castle                | 2004                | 2002          | 1978       |
| Castle                | 2016                | 2014          | 1978       |
| Classic               | 2015                | 1999          | 1998       |
| Creator               | 2001                | 1995          | 1995       |
| Dacta                 | 1976                | 1972          | 1972       |
| Dacta                 | 1979                | 1976          | 1972       |
| Dacta                 | 2002                | 1998          | 1972       |
| Duplo                 | 1972                | 1970          | 1970       |
| Duplo                 | 1975                | 1973          | 1970       |
| Education             | 1996                | 1980          | 1980       |
| Education             | 1999                | 1997          | 1980       |
| Factory               | 2007                | 2005          | 2005       |
| Gear                  | 1974                | 1972          | 1971       |
| Gear                  | 1978                | 1975          | 1971       |
| Gear                  | 1980                | 1978          | 1971       |
| Gear                  | 1983                | 1980          | 1971       |
| Gear                  | 1988                | 1985          | 1971       |
| Gear                  | 1993                | 1988          | 1971       |
| Gear                  | 1996                | 1994          | 1971       |
| Harry Potter          | 2007                | 2005          | 2001       |
| Harry Potter          | 2010                | 2007          | 2001       |
| Harry Potter          | 2018                | 2011          | 2001       |
| Hobby Set             | 1978                | 1976          | 1975       |
| Hobby Set             | 2003                | 1978          | 1975       |
| Homemaker             | 1977                | 1974          | 1971       |
| Homemaker             | 1982                | 1980          | 1971       |
| Jurassic World        | 2018                | 2015          | 2015       |
| Make and Create       | 2012                | 2007          | 2005       |
| Mindstorms            | 2004                | 2001          | 1998       |
| Mindstorms            | 2006                | 2004          | 1998       |
| Mindstorms            | 2013                | 2011          | 1998       |
| Mindstorms            | 2015                | 2013          | 1998       |
| Mindstorms            | 2020                | 2015          | 1998       |
| Minitalia             | 1973                | 1971          | 1970       |
| Minitalia             | 1977                | 1973          | 1970       |
| Miscellaneous         | 2005                | 2002          | 2002       |
| Model Team            | 1990                | 1986          | 1986       |
| Model Team            | 1993                | 1991          | 1986       |
| Model Team            | 2004                | 1999          | 1986       |
| Overwatch             | 2022                | 2019          | 2018       |
| Pirates               | 1991                | 1989          | 1989       |
| Pirates               | 2001                | 1997          | 1989       |
| Pirates               | 2009                | 2002          | 1989       |
| Pirates               | 2013                | 2009          | 1989       |
| Pirates               | 2015                | 2013          | 1989       |
| Pirates of the Caribbean | 2017            | 2011          | 2011       |
| Power Functions       | 2011                | 2009          | 2008       |
| Power Functions       | 2013                | 2011          | 2008       |
| Primo                 | 2005                | 1999          | 1995       |
| Promotional           | 1981                | 1977          | 1977       |
| Promotional           | 1985                | 1982          | 1977       |
| Promotional           | 1989                | 1986          | 1977       |
| Promotional           | 1995                | 1993          | 1977       |
| Promotional           | 1997                | 1995          | 1977       |
| Promotional           | 2001                | 1999          | 1977       |
| Racers                | 2001                | 1998          | 1998       |
| Samsonite             | 1975                | 1973          | 1970       |
| Samsonite             | 1979                | 1976          | 1970       |
| Scala                 | 1997                | 1980          | 1979       |
| Seasonal              | 2009                | 2006          | 1999       |
| Serious Play          | 2010                | 2008          | 2007       |
| Serious Play          | 2013                | 2010          | 2007       |
| Serious Play          | 2015                | 2013          | 2007       |
| Space                 | 2001                | 1999          | 1978       |
| Space                 | 2007                | 2001          | 1978       |
| Space                 | 2013                | 2011          | 1978       |
| SpongeBob SquarePants  | 2011                | 2009          | 2006       |
| Sports                | 2006                | 2004          | 2000       |
| Trains                | 1974                | 1972          | 1970       |
| Trains                | 1980                | 1978          | 1970       |
| Trains                | 1983                | 1981          | 1970       |
| Trains                | 1985                | 1983          | 1970       |
| Trains                | 1991                | 1986          | 1970       |
| Trains                | 1993                | 1991          | 1970       |
| Trains                | 2001                | 1999          | 1970       |
| Universal Building Set| 1985                | 1977          | 1970       |
| Universal Building Set| 1987                | 1985          | 1970       |
| Western               | 2002                | 1997          | 1996       |


This SQL code creates a temporary table called Rein_Themes to store data about reintroduced LEGO themes. Then, it retrieves the top 10 themes that have been reintroduced the most.

The code identifies themes that were reintroduced after a gap in production years, calculates how many times each theme has been reintroduced, and lists the top 10 themes with the most reintroductions. This helps understand which LEGO themes have been revived multiple times, indicating their potential popularity or relevance over time.
```sql
CREATE TEMPORARY TABLE Rein_Themes AS WITH ThemeProductionPeriods AS (
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
    
SELECT
    theme,
    COUNT(*) AS reintroduction_count 
FROM
    Rein_Themes
GROUP BY
    theme
ORDER BY
    reintroduction_count DESC
LIMIT 10;
```

| Theme        | Reintroduction Count |
|--------------|---------------------|
| Gear         | 7                   |
| Trains       | 7                   |
| Books        | 6                   |
| Promotional  | 6                   |
| Mindstorms   | 5                   |
| Pirates      | 5                   |
| Castle       | 4                   |
| Dacta        | 3                   |
| Boats        | 3                   |
| Model Team   | 3                   |

LEGO reintroduces themes like "Trains" and "Gear" often, probably because they're popular and timeless. This shows how LEGO balances new ideas with classic themes that people love.

#### Closing Thoughts
LEGO has been making more and more sets, especially complex ones. Popular themes like "Gear" and "Town" show how LEGO has changed over time. Licensed sets usually have more minifigures. LEGO also brings back old themes like "Trains" and "Gear," showing they know what fans like. This project helped us understand LEGO better!



























