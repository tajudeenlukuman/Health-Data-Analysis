

-- Create the encounters table
DROP TABLE IF EXISTS encounters;

CREATE TABLE encounters (
Id TEXT PRIMARY KEY,
START TIMESTAMP,
STOP TIMESTAMP,
PATIENT TEXT ,
ORGANIZATION TEXT,
PAYER TEXT ,
ENCOUNTERCLASS TEXT,
CODE TEXT,
DESCRIPTION TEXT,
BASE_ENCOUNTER_COST NUMERIC(10, 2),
TOTAL_CLAIM_COST NUMERIC(10, 2),
PAYER_COVERAGE NUMERIC(10, 2),
REASONCODE VARCHAR(20),
REASONDESCRIPTION VARCHAR(255)
);
-- Then load data from csv using the import procedure


-- Create the patients table
CREATE TABLE IF NOT EXISTS patients(
Id TEXT PRIMARY KEY,
BIRTHDATE DATE,
DEATHDATE DATE,
PREFIX TEXT,
FIRST VARCHAR(100),
LAST VARCHAR(100),
SUFFIX VARCHAR(10),
MAIDEN VARCHAR(100),
MARITAL VARCHAR(10),
RACE VARCHAR(100),
ETHNICITY VARCHAR(100),
GENDER CHAR(1),
BIRTHPLACE VARCHAR(255),
ADDRESS VARCHAR(255),
CITY VARCHAR(100),
STATE VARCHAR(100),
COUNTY VARCHAR(100),
ZIP VARCHAR(10),
LAT DOUBLE PRECISION,
LON DOUBLE PRECISION
);
-- Then load data from csv using the import procedure


-- Create payers table
CREATE TABLE IF NOT EXISTS payers (
Id TEXT PRIMARY KEY,
NAME VARCHAR(255),
ADDRESS VARCHAR(255),
CITY VARCHAR(100),
STATE_HEADQUARTERED VARCHAR(255),
ZIP VARCHAR(10),
PHONE VARCHAR(20)
);
-- Then load data from csv using the import procedure


-- Create procedures table
CREATE TABLE IF NOT EXISTS procedures (
    START TIMESTAMP,
    STOP TIMESTAMP,
    PATIENT CHAR(36),
    ENCOUNTER CHAR(36),
    CODE VARCHAR(20),
    DESCRIPTION VARCHAR(255),
    BASE_COST INT,
    REASONCODE VARCHAR(20),
    REASONDESCRIPTION VARCHAR(255)
);
-- Then load data from csv using the import procedure

-- Now all the important data has been loaded (4 tables)
-- Let the actual work begin


-- Lets duplicate all the tables so we can work on them without touching the originals



-- encounters copy
CREATE TABLE encounters1(
LIKE encounters 
INCLUDING ALL
);

INSERT INTO encounters1
SELECT * FROM encounters;



-- patients copy
CREATE TABLE patients1(
LIKE patients 
INCLUDING ALL
);

INSERT INTO patients1
SELECT * FROM patients;



--Payers copy
CREATE TABLE payers1(
LIKE payers 
INCLUDING ALL
);

INSERT INTO payers1
SELECT * FROM payers;



-- Proceures copy
CREATE TABLE procedures1(
LIKE procedures
INCLUDING ALL
);

INSERT INTO procedures1
SELECT * FROM procedures;


-- Done with copies of the tables
-- Now Lets Explore Each of the tables to see what we have
-- Lets check all the table we have and how they relate to each other.

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';
-- So we have 8 tables (4 originals and 4 copies)



-- Lets start with patients

SELECT * FROM patients1
LIMIT 20;

SELECT count(*) FROM patients1; -- 974 pateints

SELECT DISTINCT COUNT(*) FROM patients1; -- There's NO duplicates IN id

-- Lets check the max death date so we can know around when the data was collected
 SELECT Max(extract(YEAR FROM deathdate)) FROM patients1 -- 2022
 
 -- I am thinking lets populate the death date the last year 
 -- but lets hold on for now
 
 -- Lets see how many patients are still alive
 -- we assume null death date means they are still alive
 
 SELECT COUNT(*)
 FROM patients1 
 WHERE deathdate IS NOT NULL; -- 154 dead
 
 SELECT COUNT(*)
 FROM patients1 
 WHERE deathdate IS NULL; -- 820 alive 
 
 
 -- Lets add an age column
 -- but to do that we have to pupulate the deathdate to the max death date
 -- And we assume the data was collected in that year
 
 WITH age_cte AS (
 SELECT birthdate, deathdate,
 CASE 
 	WHEN deathdate IS NULL THEN '2022-12-31'
 	ELSE deathdate
 END AS current_date
 FROM patients1
 )
 SELECT *, EXTRACT(YEAR FROM AGE(current_date, birthdate)) AS age 
 FROM age_cte;

 
 -- Lets find th max age
 WITH currentdate_cte AS (
 SELECT birthdate, deathdate,
 CASE 
 	WHEN deathdate IS NULL THEN '2022-12-31'
 	ELSE deathdate
 END AS current_date, gender
 FROM patients1
 ),
 age_cte AS (
 SELECT *, EXTRACT(YEAR FROM AGE(current_date, birthdate)) AS age 
 FROM currentdate_cte
 )
 SELECT *
 FROM age_cte
 WHERE age = (SELECT max(age) FROM age_cte); -- The max age IS 103
 
 -- 7 people
-- 5 males
 -- 2 females
 
 
 -- Lets find which of the oldest are still alive
 -- This means their death date will be null
 WITH currentdate_cte AS (
 SELECT birthdate, deathdate,
 CASE 
 	WHEN deathdate IS NULL THEN '2022-12-31'
 	ELSE deathdate
 END AS current_date, gender
 FROM patients1
 ),
 age_cte AS (
 SELECT *, EXTRACT(YEAR FROM AGE(current_date, birthdate)) AS age 
 FROM currentdate_cte
 )
 SELECT *
 FROM age_cte
 WHERE age = (SELECT max(age) FROM age_cte)
 AND deathdate IS NULL; 
 -- 5 patientsm 2 females and 3 males.
 

 
 
 -- Lets try to update our table to add age in there
 ALTER TABLE patients1 
 ADD COLUMN age int;
 
 -- Okay now lets update the age column to have our calculated age
 WITH currentdate_cte AS (
 SELECT id, birthdate, deathdate,
 CASE 
 	WHEN deathdate IS NULL THEN '2022-12-31'
 	ELSE deathdate
 END AS current_date, gender
 FROM patients1
 ),
 age_cte AS (
 SELECT *, EXTRACT(YEAR FROM AGE(current_date, birthdate)) AS age 
 FROM currentdate_cte
 )
UPDATE patients1
SET age = age_cte.age
FROM age_cte
WHERE age_cte.id = patients1.id;

-- Okay lets see if that works
SELECT * FROM patients1 p 
WHERE p.age = 103
AND p.gender = 'M' 
-- Works okay.
-- We are done with analysing and adding a age column


-- Lets see what we have
SELECT * FROM patients1
LIMIT 100;



-- Lets do some cleaning.
SELECT *
FROM patients1
WHERE suffix IS NOT NULL; 
-- Only 21 ROWS, less than 0.2 percent of patients
-- lets drop this column
-- I dont think Im gonna need it. I hope.

ALTER TABLE  patients1 
DROP COLUMN suffix;

-- Lets check the prefix column
SELECT DISTINCT prefix 
FROM patients1 
-- I dont think this IS important, lets DROP it
ALTER TABLE  patients1 
DROP COLUMN prefix;

-- Also the lat and longitude, lets drop them
ALTER TABLE patients1
DROP COLUMN lat,
DROP COLUMN lon;

--Let's check maiden name
SELECT *
FROM patients1
WHERE maiden IS NOT NULL
ORDER BY 4;

-- lets check distint name combinations
SELECT FIRST,maiden, count(*)
FROM patients1
GROUP BY FIRST,maiden
ORDER BY 3 DESC
-- Okay so none of the patients have the same combination of names.
-- So we can safely drop the maiden names column


-- Droping the maiden column
ALTER TABLE patients1 
DROP COLUMN maiden;
--Lets see what we have
SELECT * FROM patients1
LIMIT 25;

-- Lets drop the zip too, I hope i dont need it.
ALTER TABLE patients1 
DROP COLUMN zip;
--Lets see what we have
SELECT * FROM patients1
LIMIT 25;

--Lets check the address
SELECT count(DISTINCT address)
FROM patients1; 
-- same AS the number OF patients so, we dont really need it
-- maybe the counties and states might be useful
-- lets drop it

ALTER TABLE patients1
DROP COLUMN address;
--Lets see what we have
SELECT * FROM patients1
LIMIT 100;


-- The only nulls we have left are the death date for those alive



-- Cool, lets analyze to see the marital distribution

-- Percentage of those patients who are are married.
SELECT round(sum(
CASE
	WHEN marital = 'M' THEN 1
	ELSE 0
END
)*100/count(*)::numeric, 2) AS married_ratio
FROM patients1;
-- 80.94

-- Percentage of those patients who are not married.
SELECT round(sum(
CASE
	WHEN marital = 'S' THEN 1
	ELSE 0
END
)::dec*100/count(*), 2) AS single_ratio
FROM patients1;
-- 19.4 %

-- Confirming
SELECT marital, count(*)
FROM patients1
GROUP BY marital
-- we have one null value.





-- Lets see the gender distribution
SELECT DISTINCT gender FROM patients1
-- We have female and males

--Percentage of males
SELECT round(sum(
CASE 
	WHEN gender = 'M' THEN 1
	ELSE 0
END
)::DEC*100/count(*), 2) AS male_ratio
FROM patients1
-- 50.72;


--Percentage of females
SELECT round(sum(
CASE 
	WHEN gender = 'F' THEN 1
	ELSE 0
END
)::DEC*100/count(*), 2) AS female_ratio
FROM patients1;
-- 49.28

-- Confirming
SELECT gender, count(*), 
round(count(*) * 100 / sum(count(*)) over() , 2) AS gender_pecentage
FROM patients1
GROUP BY gender
-- Learnt a new way to find percentages




-- Lets find the race distribution
SELECT DISTINCT race FROM patients1
-- 5 distinct races + a 6th other

--pecentages of each race
SELECT race,
count(*) AS count,
round(count(*) * 100 / sum(count(*)) over(), 2) AS race_percentage
FROM patients1
GROUP BY race
ORDER BY 3 DESC;

-- Lets do a partition by, so we can see the races and theri percentage for each person
SELECT race,
round(count(*) over(PARTITION BY race)::dec * 100 / count(*) OVER() , 2)AS race_percentage
FROM patients1;
-- This might not really be useful
-- We are done with race.


SELECT * FROM patients1
LIMIT 100;



-- lets do the ethnicty
SELECT DISTINCT ethnicity
FROM patients1;
-- Hispanic and non-hispanic

SELECT ethnicity,
round(count(*) * 100 / sum(count(*)) OVER(), 2) AS ethnicity_perc
FROM patients1
GROUP BY ethnicity
ORDER BY 1;
-- 80.39 by 19.61


-- Now lets do something like what percentage of each ethnicity is which race??

-- First partition by ethnicity to see the races spread across
SELECT ethnicity, race,
round(
	count(*) * 100 / sum(count(*)) OVER(PARTITION BY ethnicity), 2) AS ethnicity_perc
FROM patients1
GROUP BY ethnicity, race
ORDER BY 1, 3 DESC;
-- not very useful

-- Now we partition by race to see the nonhis and hispanic
SELECT race, ethnicity,
round(
	count(*) * 100 / sum(count(*)) OVER(PARTITION BY race), 2) AS ethnicity_perc
FROM patients1
GROUP BY ethnicity, race
ORDER BY 1, 3 DESC;
-- But this looks like something rrally useful
-- This is awesome
-- We are done for race and ethnicity.
-- We can do similar for gender and race or gender and ethnicity


-- We can do similar for gender and race or gender and ethnicity
SELECT gender, ethnicity,
round(
	count(*) * 100 / sum(count(*)) OVER(PARTITION BY gender), 2) AS ethnicity_perc
FROM patients1
GROUP BY ethnicity, gender
ORDER BY 1, 3 DESC;


SELECT * FROM patients1
LIMIT 100;


-- Lets see birthplace
SELECT DISTINCT birthplace
FROM patients1
-- so we have some overlapping bithplaces

-- Lets see the distribution
SELECT birthplace, count(*)
FROM patients1 p 
GROUP BY birthplace
ORDER BY 2 DESC;
-- Most of the patients were born in Boston Massachusetts US


-- Now lets see the age.
SELECT avg(age)
FROM patients1 p ;
-- 72.8

-- Lets see the median cont
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) AS median_age
FROM patients1 p ;
-- 75

-- Lets see the median disc
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY age) AS median_age
FROM patients1 p ;
-- 75

-- The median and avg are pretty close so we can say, the distribution is even



-- WE ARE DONE ANALYSING THE patients1 TABLE.
