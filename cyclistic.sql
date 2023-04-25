-- Google Data Analytics Case Study
/*
Three questions will guide the future marketing program:
1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?
*/

-- Data Cleaning
/*
2022 Historical data on Cyclistic's users have been downloaded directly from a public database to identify trends between cyclistic members and casual riders.
In order to craft an appropriate marketing strategy to convert casual riders into cyclistic members.

After obtaining 2022 historical data, we first loaded it into excel as a .csv file. We started with first removed blank cells and formatting our data to correspond to mysql data formats.
Subsequently, we created additional columns for analysis, namely, column day_of_week (1: sunday 7:saturday) and ride_length (ended - started).
Followed by, saving our changes and loading it in batches by months labelled 1:12 into mysql.
*/

CREATE DATABASE cyclistic;

USE cyclistic;
DROP TABLE IF EXISTS cyclistic_data;
DROP TABLE IF EXISTS cyclistic_analysis;

CREATE TABLE cyclistic_data(
	ride_id VARCHAR(255) NOT NULL,
    rideable_type TEXT, 
    started_at DATETIME, 
    ended_at DATETIME, 
    start_station_name TEXT,
    end_station_name TEXT, 
    member_status TEXT,
    day_of_week INT,
    ride_length TIME
);

-- load data into single dataset
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/3.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/4.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/5.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/6.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/7.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/8.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/9.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/10.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/11.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/12.csv'
INTO TABLE cyclistic_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Inspect data
SELECT 
	MIN(started_at),
    MAX(started_at)
FROM cyclistic_data
ORDER BY started_at ASC; -- confirms data import was successful

SELECT COUNT(*)
FROM cyclistic_data; -- 641,675 user data 

SELECT 
	MIN(ride_length) AS minimum,
	MAX(ride_length) AS maximum
FROM cyclistic_data; -- 00:00:00 and 23:55:22 are both outliers in our data which will cause a bias in our report. We will revisit this information again later in this script 

SELECT 
	ride_id,
    COUNT(ride_id) AS count
FROM cyclistic_data
GROUP BY ride_id
ORDER BY count DESC
LIMIT 100; -- confirms that we have a duplicate entries in our primary key
	 
DELETE FROM cyclistic_data
WHERE ride_id IN
			(	SELECT 
					ride_id
				FROM (
						SELECT
							ride_id,
							ROW_NUMBER() OVER (PARTITION BY ride_id) AS rn
						FROM cyclistic_data
			) t
 WHERE rn > 1
 ); -- 641,663/641,675 user data with distinct primary keys

-- Basic summary of our data, mode, mean and ride length
SELECT 
	ride_length,
    COUNT(*) AS count
FROM cyclistic_data
GROUP BY ride_length
ORDER BY count DESC; -- 00:05:23 mode

SELECT 
	CAST(SEC_TO_TIME(AVG(ride_length)) AS TIME)
FROM cyclistic_data; -- 27 minutes and 56 seconds is our average ride length without excluding outliers in our data

-- because our data is positively skewed (mode < mean) a boxplot with NTILE ranges would be the best option to remove outliers.
-- to maintain 90% confidence interval, by removing NTILE(1) and NTILE(20) on both tail ends to remove most outliers.
SELECT
	ride_group,
	MAX(ride_length) 
FROM (
		SELECT 
			ride_length,
			NTILE(20) OVER (ORDER BY ride_length) AS ride_group
		FROM cyclistic_data
		) AS t
WHERE ride_group = 1 OR ride_group = 19
GROUP BY ride_group; -- most of cyclistic user's ride lengths range between 00:02:23 and 00:41:23. 

-- create new table after data cleaning for additional analysis
CREATE TABLE cyclistic_analysis(
	ride_id VARCHAR(255) NOT NULL,
    rideable_type TEXT, 
    started_at DATETIME, 
    ended_at DATETIME, 
    start_station_name TEXT,
    end_station_name TEXT, 
    member_status TEXT,
    day_of_week INT,
    ride_length TIME
);

INSERT INTO cyclistic_analysis(
	ride_id,
    rideable_type, 
    started_at, 
    ended_at, 
    start_station_name,
    end_station_name, 
    member_status,
    day_of_week,
    ride_length)
SELECT *
FROM cyclistic_data
WHERE ride_length BETWEEN '00:02:23' AND '00:41:23'; -- 577,214 rows of data

-- inspect data for analysis
SELECT *
FROM cyclistic_analysis
ORDER BY started_at ASC; 

-- summary data
SELECT 
	ride_length,
    COUNT(ride_length) AS count
FROM cyclistic_analysis
GROUP BY ride_length
ORDER BY count DESC; -- 00:05:23 remains as the mode for the data

SELECT
	CAST(SEC_TO_TIME(AVG(ride_length)) AS TIME) AS average
FROM cyclistic_analysis; -- 19 minutes and 44 seconds is a more accurate average ride vs 00:27:56 

SELECT 
	CASE 
		WHEN day_of_week = 1 THEN "Sun"
        WHEN day_of_week = 2 THEN "Mon"
        WHEN day_of_week = 3 THEN "Tues"
        WHEN day_of_week = 4 THEN "Wed"
        WHEN day_of_week = 5 THEN "Thurs"
        WHEN day_of_week = 6 THEN "Fri"
        WHEN day_of_week = 7 THEN "Sat"
	END AS days,
	COUNT(day_of_week) AS count
FROM cyclistic_analysis
GROUP BY day_of_week
ORDER BY count DESC; 

/* Majority of bike rentals were from weekdays meaning rental bikes were used more for convenience to travel from home to work vice versa
  a smaller portion of our customers were using our bike for leisure on parts of saturday (split demographic) and sunday */

-- DATA ANALYSIS
-- we know that convenience is one of the main pillar of strength for cyclistic members. Having said that, the query below shows how individuals choose a membership status relative to how conveniently our bikes are situated
WITH 
ranking AS ( 
			SELECT 
					ROW_NUMBER() OVER () AS overall_rank,
					start_station_name,
					count
				FROM (
						SELECT 
							start_station_name,
							COUNT(start_station_name) AS count
						FROM cyclistic_analysis
						GROUP BY start_station_name
						ORDER BY count DESC
						) AS t3
			),
member_rank AS (
			SELECT 
				start_station_name,
                COUNT(*) AS count
			FROM cyclistic_analysis
            WHERE member_status = "member"
            GROUP BY start_station_name
            ORDER BY count DESC
            LIMIT 5)
SELECT 
	ranking.overall_rank,
    ranking.start_station_name
FROM ranking, member_rank
WHERE ranking.start_station_name = member_rank.start_station_name; 
-- top 5 member start locations are among the most popular stations. In other words, casual members are more likely to buy cyclistic membership when the location of the bike rentals are more convenient

WITH 
ranking AS ( 
			SELECT 
					ROW_NUMBER() OVER () AS overall_rank,
					start_station_name,
					count
				FROM (
						SELECT 
							start_station_name,
							COUNT(start_station_name) AS count
						FROM cyclistic_analysis
						GROUP BY start_station_name
						ORDER BY count DESC
						) AS t3
			),
casual_rank AS (
			SELECT 
				start_station_name,
                COUNT(*) AS count
			FROM cyclistic_analysis
            WHERE member_status = "casual"
            GROUP BY start_station_name
            ORDER BY count DESC
            LIMIT 5)
SELECT 
	ranking.overall_rank,
    ranking.start_station_name
FROM ranking, casual_rank
WHERE ranking.start_station_name = casual_rank.start_station_name;
-- while most of the top 5 casual start locations are not among the top 10 highest rental locations.

SELECT
	member_status,
	CAST(SEC_TO_TIME(AVG(ride_length)) AS TIME) AS average_ride
FROM cyclistic_analysis
GROUP BY member_status; -- approximately 5 minutes difference between the average ride lengths of casual vs members, why? Apart from location

SELECT 
	rideable_type,
    CAST(SEC_TO_TIME(AVG(ride_length)) AS TIME) AS average_ride
FROM cyclistic_analysis
GROUP BY rideable_type; 

TABLE cyclistic_analysis ORDER BY started_at
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tab_cyclistic.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';

/* When compared against other ride types, docked bikes average ride is substantially higher at 33 minutes. 
Therefore the use of docked bikes actually proves to be more inconvenient for cyclistic users and location of docked stations needs to be restrategised or placed in fixed areas with singular entry and exit points
or make electric bikes only exclusive to members 

Summary
1. Tuesday, Thursday and Wednesday tend to have the highest rentals. Therefore any promotions and marketing strategies should be focused more on weekdays to get the highest sales exposure.
2. It is likely that by restrategising docking locations or removing docked bikes or by make electric bikes exclusive to members. 
	It could bring down average ride times and bring more convenience to cyclistic users.
3. With convenience being the pillar for cyclistic business model, it can be seen that there were significantly more cyclistic members in the top locations (highest mode locations) vs casual riders.
	Cyclistic should reposition/ obtain more bikes in popular casual riders locations as well to make cyclistic membership more appealing.
*/ 
