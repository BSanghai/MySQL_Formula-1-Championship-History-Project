Create database Formula_1_Championship_History;

-- Get all table names of a particular Database from MySQL

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE ='BASE TABLE' AND TABLE_SCHEMA = 'formula_1_championship_history';

-- 1. Driver Performance
-- Q1. Career statistics: 
-- A.Calculate total races --
 SELECT COUNT(*) AS total_races FROM race_results;
 -- B. Calculate wins-- 
SELECT sum(dr.wins) AS wins, dd.forename, dd.surname 
FROM driver_rankings AS dr
INNER JOIN driver_details AS dd
ON
dr.driverId = dd.driverId
GROUP BY dr.wins, dd.forename, dd.surname
ORDER BY wins DESC limit 5;
-- C. Race status analysis -- 
SELECT rr.driverId, rr.position, rr.points, rs.statusId, rs.status
from race_status AS rs
INNER JOIN race_results AS rr
ON
rs.statusId = rr.statusId
GROUP BY rr.driverId, rr.position,rr.points, rs.statusId, rs.status
ORDER BY rr.points AND rr.position DESC LIMIT 10;



-- Q2.Head-to-head comparisons: Compare the performance of different drivers against each other --
SELECT
  driver1.forename AS driver1_name,
  driver2.forename AS driver2_name,
  COUNT(CASE WHEN rr1.position < rr2.position THEN 1 END) AS driver1_wins,
  COUNT(CASE WHEN rr2.position < rr1.position THEN 1 END) AS driver2_wins,
  COUNT(CASE WHEN rr1.position <= 3 AND rr2.position <= 3 THEN 1 END) AS total_podiums,
  SUM(CASE WHEN rr1.position = 1 AND rr2.position <= 3 THEN 1 END) AS driver1_podiums,
  SUM(CASE WHEN rr2.position = 1 AND rr1.position <= 3 THEN 1 END) AS driver2_podiums,
  SUM(CASE WHEN rr1.position = 1 AND rr2.position = 2 THEN 1 END) AS driver1_second_places,
  SUM(CASE WHEN rr2.position = 1 AND rr1.position = 2 THEN 1 END) AS driver2_second_places,
  SUM(CASE WHEN rr1.position = 1 AND rr2.position = 3 THEN 1 END) AS driver1_third_places,
  SUM(CASE WHEN rr2.position = 1 AND rr1.position = 3 THEN 1 END) AS driver2_third_places
FROM
  driver_details AS driver1
  INNER JOIN race_results AS rr1 ON driver1.driverId = rr1.driverId
  INNER JOIN driver_details AS driver2 ON driver1.driverId <> driver2.driverId
  INNER JOIN race_results AS rr2 ON driver2.driverId = rr2.driverId
WHERE
  rr1.raceId = rr2.raceId
GROUP BY
  driver1.forename,
  driver2.forename
  ORDER BY 
  driver1_wins DESC,
  driver2_wins DESC
  LIMIT 5;


-- Q3.Performance trends: Analyze how drivers' performance has evolved over time.--
 SELECT
  dd.forename,
  rs.year,
  AVG(rr.position) AS average_position
FROM
  driver_details AS dd
  INNER JOIN race_results AS rr ON dd.driverId = rr.driverId
  INNER JOIN race_schedule AS rs ON rr.raceId = rs.raceId
GROUP BY
  dd.forename,
  rs.year
 ORDER BY rs.year DESC LIMIT 10;


-- Q4.Constructor championships: Identify the most successful constructors and their dominance. --
SELECT td.constructorId, td.name, td.name, td.url,
rr.rank, rr.position, cr.wins
FROM team_details AS td
INNER JOIN constructor_rankings AS cr
ON
td.constructorId = cr.constructorId
INNER JOIN race_results AS rr
ON
td.constructorId = rr.constructorId
GROUP BY 
td.constructorId, td.name, td.name, td.url,
rr.rank, rr.position, cr.wins
ORDER BY rr.rank ASC;

-- Q5.What is the average number of points scored by drivers per season, and how has this changed over the decades? --

    
 SELECT 
    CONCAT(FLOOR(race_schedule.year / 10) * 10, 's') AS decade,
    ROUND(AVG(driver_season_points.total_points), 2) AS avg_points_per_driver
FROM 
    (SELECT 
        driver_rankings.driverId,
        race_schedule.year,
        SUM(driver_rankings.points) AS total_points
    FROM 
        driver_rankings
    JOIN race_schedule ON driver_rankings.raceId = race_schedule.raceId
    GROUP BY 
        driver_rankings.driverId,
        race_schedule.year) AS driver_season_points
JOIN race_schedule ON driver_season_points.year = race_schedule.year
GROUP BY 
    decade
ORDER BY 
    decade;   
    
-- Q6. Who are the top 10 drivers with the most race wins, and what percentage of their total races did they win?--

SELECT 
    dd.forename,
    dd.surname,
    SUM(dr.wins) AS total_wins,
    COUNT(DISTINCT dr.raceId) AS total_races,
    ROUND(SUM(dr.wins) / COUNT(DISTINCT dr.raceId) * 100, 1) AS win_percentage
FROM 
    driver_rankings dr
JOIN driver_details dd ON dr.driverId = dd.driverId
GROUP BY 
    dr.driverId, dd.forename, dd.surname
ORDER BY 
    total_wins DESC
LIMIT 10;    

-- Q7. Which constructors have dominated different eras (e.g., 1950s, 1960s, etc.) based on the number of constructor championships won?--

SELECT dd.forename, dd.surname, dd.nationality, dr.position, dr.wins, rs.year
FROM driver_rankings AS dr
JOIN driver_details AS dd
ON 
dr.driverId = dd.driverId
JOIN race_schedule AS rs
ON
rs.raceId = dr.raceId
GROUP BY
dd.forename, dd.surname, dd.nationality, dr.position, dr.wins, rs.year
ORDER BY rs.year desc;

-- Q8. Analyze the impact of regulation changes on team performance by comparing the points distribution before and after major rule changes.  (Q16)--

SELECT td.constructorId, td.name, srr.position, srr.points, dd.forename, dd.surname,rs.year
FROM team_details AS td
JOIN sprint_race_results AS srr
ON
td.constructorId = srr.constructorId
JOIN driver_details AS dd
ON
srr.driverId = dd.driverId
JOIN race_schedule AS rs
ON
srr.raceId = rs.raceId
GROUP BY
td.constructorId, td.name, srr.position, srr.points, dd.forename, dd.surname,rs.year
ORDER BY td.constructorId ASC;