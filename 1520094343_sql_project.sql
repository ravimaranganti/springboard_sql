/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT facid, name, membercost
FROM country_club.Facilities
WHERE membercost  != 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT facid, name, membercost
FROM country_club.Facilities
WHERE membercost  = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM country_club.Facilities
WHERE (membercost>0) and (membercost < 0.2*monthlymaintenance)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
FROM country_club.Facilities
WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT 
	name,
	monthlymaintenance,
	CASE WHEN monthlymaintenance <=100 THEN 'cheap'
	ELSE 'expensive' END AS cheap_or_expensive
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT surname,
		firstname,
		max(joindate)
FROM country_club.Members
WHERE surname  != "GUEST"

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(Members.firstname,' ',Members.surname) AS Full_Name, Facilities.name
	FROM country_club.Members Members
  JOIN country_club.Bookings Bookings
    ON Members.memid = Bookings.memid
	JOIN country_club.Facilities Facilities
	ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE 'Tennis Court%' AND Members.firstname !='GUEST'
ORDER BY Full_Name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT  Facilities.name AS Facilities_Name,
		CONCAT(Members.firstname,' ',Members.surname) AS Full_Name, 
		CASE WHEN (Members.firstname= 'GUEST')   THEN Facilities.guestcost* Bookings.slots 
		     WHEN (Members.firstname !='GUEST')  THEN Facilities.membercost* Bookings.slots  
			 END AS 'Cost_total'

FROM country_club.Members Members
  JOIN country_club.Bookings Bookings
    ON Members.memid = Bookings.memid
	JOIN country_club.Facilities Facilities
	ON Bookings.facid = Facilities.facid

WHERE (starttime LIKE '2012-09-14%') 
	 	AND ((Members.memid =0 and Facilities.guestcost* Bookings.slots >30)
             OR (Members.memid =1 and Facilities.membercost* Bookings.slots >30))
		

ORDER BY Cost_total DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT  Sub.name  AS Facilities_Name,
		CONCAT(Sub.firstname,' ',Sub.surname) AS Full_Name,
		Sub.Cost_Total

FROM

( 
    SELECT Members.firstname, Members.surname,Members.memid, Facilities.name,Bookings.facid, Bookings.starttime,
		CASE WHEN Members.firstname= 'GUEST' THEN Facilities.guestcost* Bookings.slots 
		ELSE Facilities.membercost*Bookings.slots END AS 'Cost_total'
		FROM country_club.Members Members
  		JOIN country_club.Bookings Bookings
    	ON Members.memid = Bookings.memid
		JOIN country_club.Facilities Facilities
		ON Bookings.facid = Facilities.facid
 ) Sub

WHERE Sub.starttime LIKE '2012-09-14%' AND Sub.Cost_total > 30

ORDER BY Sub.Cost_total DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT Sub.*

FROM
(
	SELECT  
	Facilities.name,		
		(SUM(CASE WHEN (Members.firstname= 'GUEST')   THEN Facilities.guestcost* Bookings.slots 
     	END))   +(SUM(CASE WHEN (Members.firstname!= 'GUEST')   THEN Facilities.membercost* Bookings.slots 
     	END)) AS 'Total_Revenue'  
		    		     
		
	FROM country_club.Members Members
  	JOIN country_club.Bookings Bookings
    ON Members.memid = Bookings.memid
	JOIN country_club.Facilities Facilities
	ON Bookings.facid = Facilities.facid
	GROUP BY Facilities.name ) Sub
WHERE Sub.Total_Revenue < 1000

ORDER BY Sub.Total_Revenue
