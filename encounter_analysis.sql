-- We will analyse the encounter1 table here

SELECT count(*) FROM encounters1; -- 27, 891 ROWS

SELECT count(DISTINCT id) FROM encounters1;


SELECT * FROM encounters1 e
LIMIT 50;

SELECT count(*) FROM encounters1; -- 27,891 encounters

-- Lets check the unique patient enconyers

SELECT count(DISTINCT patient) FROM encounters1; -- we have 974 distinctint patients


-- Lets find the average number of encounters per patient
-- but First lets find the count of encounters per patient


SELECT DISTINCT patient, count(patient)
FROM encounters1 e
GROUP BY patient
ORDER BY 2 DESC;
-- wow one patient had 1k+ encounters

-- The distribution is not normal, so the average will not be a correct measure.
-- Lets confirm that checking the average and median.
-- Maybe the median will be a good measure



-- Average VS Median
SELECT 
Round(count(*)::DEC / COUNT(DISTINCT patient)
,2) AS average_num_enc
FROM encounters1 e; -- 28.64


SELECT 27891/974::dec; -- manual calulation OF average -- 28.64, correct.

-- Comparing the mean and the median, we see that the distribution is not normal
-- The the mean is not an accurage measure in this case.


-- Now the median
SELECT
percentile_cont(0.5) WITHIN GROUP (ORDER BY counts) AS median
FROM (
	SELECT count(*) AS counts 
	FROM encounters1 
	GROUP BY patient
);-- 14
-- This means that 50% of the patients had less 14 encounters and less


-- Lets do the 96% percentile
SELECT
percentile_disc(0.96) WITHIN GROUP (ORDER BY counts) AS median
FROM (
	SELECT count(*) AS counts 
	FROM encounters1 
	GROUP BY patient
);
-- This means that only ~5% of the patients had modre than 100 encounters



-- Lets see how amny patients had encounters less than the calculated mean encounter count.

SELECT count(*) 
FROM (
	SELECT DISTINCT patient, count(*) AS g1
	FROM encounters1 e
	GROUP BY patient
	HAVING  count(*) < 28
); -- 723 patients had less than the mean(ie 28) encunters.




-- Analysis: Lets find how many encounters occured each year
SELECT * FROM encounters1 e
LIMIT 50;

SELECT extract(YEAR FROM start) AS start_year,
extract(YEAR FROM stop) AS stop_year,
count(*) AS encounter_per_year
FROM encounters1 e
GROUP BY 1,2
ORDER BY 3 DESC; 
-- FROM 2011 TO 2022
-- 2014 had the highest encounter = 3885


SELECT extract(YEAR FROM start) AS start_year,
extract(YEAR FROM stop) AS stop_year,
count(*) AS encounter_per_year
FROM encounters1 e
GROUP BY 1,2
HAVING  extract(YEAR FROM start) <>  extract(YEAR FROM stop)
ORDER BY 3 DESC; 
-- There are some patients whose encounter start and stop years are different
-- That opens up new questions.
-- Do the encounters lead to admision or end at consultation. (Oh I guess we have a column for that)
-- We would explore that.
-- Lets check the description column to see what really happened fro those patients


SELECT * FROM encounters1 e
LIMIT 30;


SELECT e.patient, 
		extract(YEAR FROM e.start) AS start_year, 
		extract(YEAR FROM stop) AS stop_year, 
		e.description,
		e.reasondescription,
		e.encounterclass
FROM encounters1 e
WHERE extract(YEAR FROM start) <>  extract(YEAR FROM stop); 


---- The description tell us the that those people either came for a procedure or follow up procedure
--- Most of them were either ambulatory or inpatient.
--- Lets get a clear picture by seeing the entire date
-- Because for most of them, then start and stop years are successive, like 2014 then 2015.
-- Probably a 31st december night encounter. Lets check that.


SELECT e.patient, 
		date_trunc('day', e.start) AS start_year, 
		date_trunc('day', e.stop) AS stop_year, 
		e.encounterclass,
		age(e.stop, e.start) AS interval
FROM encounters1 e
WHERE extract(YEAR FROM start) <>  extract(YEAR FROM stop); 

--- the encounter class mostly do not match the interval of stay
-- I would expert an inpatient to stay overnight
-- And outpatient and ambulatory to be aff in less than a couple of hours
-- But the results here show an outpatient with interval between start and stop date to b1 11+ months.
-- Ajeeb (word for strange in arabic)
-- Unless!!!!
-- Maybe the stop timestamp was entered wrongly or something of the sort.




-- Lets confirm for others. 
-- For each encounterclass to make sure we know what is wrong



-- For outpatient
-- We expect them to be off within the a couple of minutes.
-- Lets check that
SELECT e.patient, 
		e.start,
		e.stop,
		e.encounterclass,
		age(e.stop, e.start) AS interval
FROM encounters1 e
WHERE encounterclass LIKE 'outpatient'
ORDER BY 5 desc; 

--- So we have a majority of outpatients interval to be reasonable.
-- Within 2 hours, they are mostly off.
-- But we have a few that are over 1 day.
-- I would need an explanation for that!!!


-- Lets do the same for ambulatory
-- Im hoping we find similar results
SELECT e.patient, 
		e.start,
		e.stop,
		e.encounterclass,
		age(e.stop, e.start) AS interval
FROM encounters1 e
WHERE encounterclass LIKE 'ambulatory'
ORDER BY 5 desc;

-- Okay. Reasonable within 3 to 4 hours interval
-- With a few unreasonable ones. like 5 years. Ajeeb.






-----------------Lets move on to the next analysis-----------------
-- For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?
-------------------------------------------------------------------

SELECT 
	extract(YEAR FROM start) AS start_year,
	encounterclass,
	count(*) AS encounter_per_year,
	round(
		count(*) * 100 / sum(count(*)) OVER(PARTITION BY extract(YEAR FROM start))
	,2) AS class_perc
FROM encounters1 e
GROUP BY 2, 1
ORDER BY 1, 3 desc;

-- So, for each year, we find the encounter class and their distribution



-- Now lets find the top encounterclass for each year
-- We can use cte and then row number

WITH rankedcte AS (
	SELECT 
		extract(YEAR FROM start) AS year,
		e.encounterclass,
		count(*) AS encounter_per_year,
		round(
			count(*) * 100 / sum(count(*)) OVER(PARTITION BY extract(YEAR FROM start))
		,2) AS class_perc,
		ROW_number() OVER(PARTITION BY extract(YEAR FROM start) ORDER BY count(*) desc) AS rn
	FROM encounters1 e
	GROUP BY 2, 1
	ORDER BY 1
)
SELECT * FROM rankedcte
WHERE rn = 1;

-- Interesting.
-- Except for 2021, we see that 'ambulatory' class had the highest percentages across all years.
-- 2021 had Outpatient (which is almost synonymous to ambulatory)





-----------------Lets move on to the next analysis-----------------
-- c. What percentage of encounters were over 24 hours versus under 24 hours?
-------------------------------------------------------------------

-- we can use case statemnt with cte

WITH durationcte AS (
	SELECT 
	id, 
	age(stop, start) AS duration
	FROM encounters1 e
)
SELECT
ROUND(avg(CASE WHEN duration < INTERVAL '1 days' THEN 1 ELSE 0 END)*100 , 2) AS under_24,
ROUND(avg(CASE WHEN duration >= INTERVAL '1 days' THEN 1 ELSE 0 END)*100 , 2) AS over_24
FROM durationcte;
-- 95.87% of encounters were less than 24 hours




--- We are done For Now
