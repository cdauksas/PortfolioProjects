-- How many players are in each position from the attacking table?
Select position, count(position)
From UCL.dbo.attacking$
Group by position

--Partition by clauses to see how many total positions there are in each line
Select player_name, position, COUNT(position) OVER (PARTITION BY position)
From UCL.dbo.attacking$

--Partition by caluse to see the total amount of offsides by club
SELECT club, position, SUM(offsides) OVER (PARTITION by club) as TotClubOffsides
FROM UCL.dbo.attacking$

-- Who were the top 10 goal scorers in the UCL 2021? order by rank desc
Select TOP 10 player_name, position, goals, DENSE_RANK() OVER (Order by goals desc) as 'DenseRank'
From UCL.dbo.goals$


--Look at relationship between attempts and goals
SELECT a.player_name, a.total_attempts, g.goals
FROM UCL.dbo.attempts$ a
JOIN UCL.dbo.goals$ g
ON a.player_name = g.player_name
Order by a.total_attempts desc


--Create a new column, and for players who scored more with their right foot the value will be 'Right'. Left will be 'Left'
SELECT player_name, goals, right_foot, left_foot,
CASE WHEN right_foot > left_foot Then 'Right Footer'
WHEN right_foot = left_foot Then 'Neutral'
ELSE 'Left Footer' END AS FOOT
FROM UCL.dbo.goals$ 

--Which teams made it to the final?
SELECT Distinct club, match_played
From UCL.dbo.goals$
Order by match_played desc

-- Which club had the most red cards? Incomplete
	SELECT club, SUM(red) as TotReds
	FROM UCL.dbo.disciplinary$
	GROUP BY club
	ORDER BY TotReds desc

-- Which club had the most Total Cards?
SELECT club, SUM(red + yellow) as TotCards
	FROM UCL.dbo.disciplinary$
	GROUP BY club
	ORDER BY TotCards desc

--Did any players who scored more than 10 goals get a red card?
SELECT r.player_name, l.red, r.goals
FROM UCL.dbo.disciplinary$ l
INNER JOIN UCL.dbo.goals$ r
ON r.player_name = l.player_name
WHERE goals >= 10 and red >= 1

 

--How many players are in each position?
Select * --, position, count(position)
From UCL.dbo.attacking$ atck
JOIN UCL.dbo.goals$ gol
ON atck.player_name = gol.player_name
Group by position

Select *
From UCL.dbo.attacking$
