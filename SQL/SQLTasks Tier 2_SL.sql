/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name FROM Facilities
WHERE membercost != 0.0



/* Q2: How many facilities do not charge a fee to members? */

SELECT count(*) FROM Facilities
WHERE membercost = 0.0


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance 
AND membercost != 0.0

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities
WHERE facid IN (1,5)


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE When monthlymaintenance > 100 THEN "Expensive"
	ELSE "Cheap" END AS label
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT surname, firstname 
FROM Members
WHERE joindate = (
    SELECT max(joindate)
    FROM Members
    )


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT Distinct f.name AS Facility, CONCAT_WS(' ',m.surname,m.firstname) AS fullname
FROM Facilities AS f
INNER JOIN Bookings AS b
ON b.facid=f.facid
INNER JOIN Members AS m
ON m.memid=b.memid
WHERE f.name Like "Tennis Court %"
ORDER BY fullname


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS Facility, CONCAT_WS(' ',m.surname,m.firstname) AS fullname, 
CASE WHEN m.memid = 0 THEN b.slots*f.guestcost
	ELSE b.slots*f.membercost END AS Cost
FROM Facilities AS f
INNER JOIN Bookings AS b
ON b.facid=f.facid
INNER JOIN Members AS m
ON m.memid=b.memid
WHERE b.starttime LIKE "2012-09-14%" AND CASE 
    WHEN m.memid = 0 THEN b.slots*f.guestcost > 30
    ELSE b.slots*f.membercost>30 END
    
ORDER BY Cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT * FROM
(
SELECT f.name AS Facility, CONCAT_WS(' ',m.surname,m.firstname) AS fullname, 
CASE WHEN m.memid = 0 THEN b.slots*f.guestcost
	ELSE b.slots*f.membercost END AS Cost
FROM Facilities AS f
INNER JOIN Bookings AS b
ON b.facid=f.facid
INNER JOIN Members AS m
ON m.memid=b.memid
WHERE b.starttime LIKE "2012-09-14%"
ORDER BY Cost DESC
    ) AS C
WHERE C.Cost > 30


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


import pandas as pd
from sqlalchemy import create_engine
engine=create_engine("sqlite:///sqlite_db_pythonsqlite.db")
df=pd.read_sql_query("SELECT c.facility_name, sum(c.revenue) FROM (SELECT f.name AS facility_name, CASE WHEN b.memid =0 THEN b.slots*f.guestcost ELSE b.slots*f.membercost END AS revenue FROM Facilities AS f JOIN Bookings AS b ON f.facid = b.facid JOIN Members AS m ON m.memid = b.memid)AS c GROUP BY c.facility_name ORDER BY sum(c.revenue)", engine)
print(df.head())

     facility_name  sum(c.revenue)
0     Table Tennis           180.0
1    Snooker Table           240.0
2       Pool Table           270.0
3  Badminton Court          1906.5
4     Squash Court         13468.0
5   Tennis Court 1         13860.0
6   Tennis Court 2         14310.0
7   Massage Room 2         14454.6
8   Massage Room 1         50351.6



/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

df=pd.read_sql_query("SELECT m1.surname, m1.firstname, m2.surname AS referral_surname, m2.firstname AS referral_firstname FROM Members AS m1 LEFT JOIN Members as m2 ON m1.recommendedby = m2.memid ORDER BY m2.surname, m2.firstname", engine)
print(df)

              surname  firstname referral_surname referral_firstname
0               GUEST      GUEST             None               None
1               Smith     Darren             None               None
2               Smith      Tracy             None               None
3              Rownam        Tim             None               None
4               Tracy     Burton             None               None
5             Farrell     Jemima             None               None
6             Farrell      David             None               None
7          Tupperware   Hyacinth             None               None
8               Smith     Darren             None               None
9              Sarwin  Ramnaresh            Bader           Florence
10             Coplin       Joan            Baker            Timothy
11            Genting    Matthew          Butters             Gerald
12              Baker    Timothy          Farrell             Jemima
13             Pinker      David          Farrell             Jemima
14             Rumney  Henrietta          Genting            Matthew
15              Jones    Douglas            Jones              David
16               Dare      Nancy         Joplette             Janice
17              Jones      David         Joplette             Janice
18               Hunt       John          Purview          Millicent
19             Boothe        Tim           Rownam                Tim
20           Joplette     Janice            Smith             Darren
21            Butters     Gerald            Smith             Darren
22               Owen    Charles            Smith             Darren
23              Smith       Jack            Smith             Darren
24          Mackenzie       Anna            Smith             Darren
25  Worthington-Smyth      Henry            Smith              Tracy
26            Purview  Millicent            Smith              Tracy
27            Crumpet      Erica            Smith              Tracy
28              Baker       Anne         Stibbons             Ponder
29              Bader   Florence         Stibbons             Ponder
30           Stibbons     Ponder            Tracy             Burton

/* Q12: Find the facilities with their usage by member, but not guests */

df=pd.read_sql_query("SELECT f.name, sum(b.slots) FROM Facilities as f JOIN Bookings as b ON f.facid=b.facid WHERE b.memid !=0 GROUP BY f.name  ", engine)
print(df)
              name  sum(b.slots)
0  Badminton Court          1086
1   Massage Room 1           884
2   Massage Room 2            54
3       Pool Table           856
4    Snooker Table           860
5     Squash Court           418
6     Table Tennis           794
7   Tennis Court 1           957
8   Tennis Court 2           882

/* Q13: Find the facilities usage by month, but not guests */

df=pd.read_sql_query("SELECT strftime('%m',b.starttime), sum(b.slots) FROM Facilities as f JOIN Bookings as b ON f.facid=b.facid WHERE b.memid !=0 GROUP BY strftime('%m',b.starttime)  ", engine)
print(df)

  strftime('%m',b.starttime)  sum(b.slots)
0                         07          1061
1                         08          2531
2                         09          3199

