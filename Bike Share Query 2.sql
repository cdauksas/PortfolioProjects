------ Combining tables into one ------
SELECT * INTO tot_data

FROM

(
SELECT * from bikeshare.dbo.dec_2020$
UNION all
SELECT * from bikeshare.dbo.jan_2021$
UNION ALL
SELECT * from bikeshare.dbo.feb_2021$
UNION all
SELECT * from bikeshare.dbo.mar_2021$
union all
SELECT * from bikeshare.dbo.apr_2021$
UNION all
SELECT * from bikeshare.dbo.may_2021$
UNION ALL
SELECT * from bikeshare.dbo.june_2021$
UNION all 
SELECT * from bikeshare.dbo.july_2021$
UNION all
SELECT * from bikeshare.dbo.aug_2021$
UNION all
SELECT * from bikeshare.dbo.sep_2021$
UNION all 
SELECT * from bikeshare.dbo.oct_2021$
UNION all
SELECT * from bikeshare.dbo.nov_2021$) A

select top 10 * from tot_data


-----Adding a new column to calcuate each ride duration--------

ALTER TABLE tot_data
ADD duration int

UPDATE tot_data
SET duration = DATEDIFF(MINUTE, started_at, ended_at)

------ Extracting month and year and adding them as new columns ------

ALTER TABLE tot_data
ADD day_of_week nvarchar(50),
month_m nvarchar(50),
year_y nvarchar(50)

UPDATE tot_data
SET day_of_week = DATENAME(WEEKDAY, started_at),
month_m = DATENAME(MONTH, started_at),
year_y = year(started_at)

--Creating month integer column
ALTER TABLE tot_data       
ADD month_int int

UPDATE tot_data          
SET month_int = DATEPART(MONTH, started_at)

-- Creating date column
ALTER TABLE tot_data    
ADD date_yyyy_mm_dd date

UPDATE tot_data            
SET date_yyyy_mm_dd = CAST(started_at AS date)






-------- Trim station name to make sure there is no extra space. Also replace (*), (Temp), filter out row with(LBS-WH-TEST) in start station name
ALTER TABLE tot_data
ADD start_station_name_cleaned nvarchar(255)



Update tot_data
Set start_station_name_cleaned = TRIM(REPLACE
		(REPLACE
		(start_station_name, '(*)',''), '(TEMP)','')) 
	FROM tot_data
	WHERE start_station_name NOT LIKE '%(LBS-WH-TEST)%' 

ALTER TABLE tot_data
ADD end_station_name_cleaned nvarchar(255)

Update tot_data
Set end_station_name_cleaned = TRIM(REPLACE
		(REPLACE
		(start_station_name, '(*)',''), '(TEMP)','')) 
	FROM tot_data
	WHERE end_station_name NOT LIKE '%(LBS-WH-TEST)%'
	
	/* Deleted rows where (NULL values), (ride length = 0), (ride length < 0), (ride_length > 1 day (1440 mins))
   for accurate analysis */

DELETE FROM tot_data
Where ride_id IS NULL OR
start_station_name IS NULL OR
end_station_name IS NULL OR
start_station_id IS NULL OR
end_station_id IS NULL OR
duration IS NULL OR
duration = 0 OR
duration < 0 OR
duration > 1440 

-- Checking for any duplicates

Select Count(DISTINCT(ride_id)) AS uniq,
Count(ride_id) AS total
From tot_data_cleaned

--Rename member_casual to user_type
EXEC sp_RENAME 'tot_data.member_casual', 'user_type', 'COLUMN'

----- Members vs Casual riders grouped by day of the week------

Create View users_per_day AS
Select 
Count(case when user_type = 'member' then 1 else NULL END) AS num_of_members,
Count(case when user_type = 'casual' then 1 else NULL END) AS num_of_casual,
Count(*) AS num_of_users,
day_of_week
FROM tot_data
GROUP BY day_of_week


----- Calculating Average Ride Length for Each User Type  -----

select top 100 * from tot_data

Create View avg_ride_length AS
SELECT user_type, AVG(duration) AS avg_ride_length, day_of_week 
From tot_data
Group BY user_type, day_of_week

-- Calculating User Traffic Every Month Since Startup

Select month_int AS Month_Num,
month_m AS Month_Name, 
year_y AS Year_Y,
Count(case when user_type = 'member' then 1 else NULL END) AS num_of_member,
Count(case when user_type = 'casual' then 1 else NULL END) AS num_of_casual,
Count(user_type) AS total_num_of_users
From tot_data
Group BY year_y, month_int, month_m
ORDER BY year_y, month_int, month_m

--casual vs member by month
Select month_m, 
Count(case when user_type = 'member' then 1 else NULL END) AS num_of_member,
Count(case when user_type = 'casual' then 1 else NULL END) AS num_of_casual
From tot_data
Group BY month_m

--Top 5 locations for casual riders
Select top 5 start_station_name, 
Count(case when user_type = 'casual' then 1 else NULL END) AS num_of_casual
From tot_data
Group BY start_station_name
Order by num_of_casual desc