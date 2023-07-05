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

SELECT name 
FROM Facilities
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) as num_no_charge 
FROM Facilities
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < monthlymaintenance * 0.2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * 
FROM Facilities
WHERE facid in (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance < 101 THEN 'cheap'
    ELSE'expensive' END
    AS label
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate
FROM Members

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT Members.memid, CONCAT(firstname, ' ', Facilities.name) AS booking
FROM Members
INNER JOIN Bookings
ON Members.memid = Bookings.memid
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Facilities.facid in (0,1);




/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT DISTINCT Members.memid, CONCAT(firstname, ' ', Facilities.name) AS booking, Facilities.guestcost, Facilities.membercost, slots,
CASE WHEN Members.memid = 0 THEN Facilities.guestcost * slots ELSE Facilities.membercost * slots END AS cost
FROM Members
INNER JOIN Bookings
ON Members.memid = Bookings.memid
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Bookings.starttime LIKE '2012-09-14%'
ORDER BY cost DESC
LIMIT 8;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT 
  Members.firstname,
  CASE WHEN Members.memid = 0 THEN b.guestcost * slots     ELSE b.membercost * slots END AS cost
FROM Members
INNER JOIN
(SELECT 
  Facilities.name,
  Facilities.membercost, 
  Facilities.guestcost,
  Bookings.memid,
  Bookings.slots
FROM Facilities
INNER JOIN Bookings
ON Facilities.facid = Bookings.facid
WHERE starttime LIKE '2012-09-14%') b
ON Members.memid = b.memid
ORDER BY cost DESC
LIMIT 8;



/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT subquery2.name, sum(subquery2.revenue) as total_revenue
FROM (SELECT 
  b.name,
  CASE WHEN Members.memid = 0 THEN b.guestcost * slots     ELSE b.membercost * slots END AS revenue
FROM Members
INNER JOIN
(SELECT 
  Facilities.name,
  Facilities.membercost, 
  Facilities.guestcost,
  Bookings.memid,
  Bookings.slots
FROM Facilities
INNER JOIN Bookings
ON Facilities.facid = Bookings.facid) b
ON Members.memid = b.memid) subquery2
GROUP BY subquery2.name
HAVING total_revenue < 1000

2.6.0
2. Query all tasks
('Pool Table', 270)
('Snooker Table', 240)
('Table Tennis', 180)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT Members.firstname, recommendors.recommendor
FROM Members
INNER JOIN(SELECT 
  m1.recommendedby,
  m2.surname AS recommendor,
  m1.memid
FROM Members as m1
INNER JOIN Members as m2
ON m1.recommendedby = m2.memid
WHERE m1.recommendedby > 0) recommendors
ON Members.memid = recommendors.memid
ORDER BY recommendor

2.6.0
2. Query all tasks
('Ramnaresh', 'Bader')
('Joan', 'Baker')
('Matthew', 'Butters')
('Timothy', 'Farrell')
('David', 'Farrell')
('Henrietta', 'Genting')
('Douglas', 'Jones')
('Nancy', 'Joplette')
('David', 'Joplette')
('John', 'Purview')
('Tim', 'Rownam')
('Janice', 'Smith')
('Gerald', 'Smith')
('Charles', 'Smith')
('Jack', 'Smith')
('Anna', 'Smith')
('Henry', 'Smith')
('Millicent', 'Smith')
('Erica', 'Smith')
('Anne', 'Stibbons')
('Florence', 'Stibbons')
('Ponder', 'Tracy')

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT subquery.fullname, Facilities.name, COUNT(*) AS facility_usage
FROM(SELECT 
  firstname + surname) AS fullname,
  Bookings.bookid,
  Bookings.facid,
  Members.memid
FROM Bookings
INNER JOIN Members
ON Bookings.memid = Members.memid
WHERE Members.memid NOT IN (0)) AS subquery
INNER JOIN Facilities
ON subquery.facid = Facilities.facid
GROUP BY fullname, Facilities.name
ORDER BY facility_usage DESC

2.6.0
2. Query all tasks
(0, 'Pool Table', 783)
(0, 'Massage Room 1', 421)
(0, 'Snooker Table', 421)
(0, 'Table Tennis', 385)
(0, 'Badminton Court', 344)
(0, 'Tennis Court 1', 308)
(0, 'Tennis Court 2', 276)
(0, 'Squash Court', 195)
(0, 'Massage Room 2', 27)

/* Q13: Find the facilities usage by month, but not guests */
SELECT name, month, COUNT(month)
FROM (SELECT 
  STRFTIME("%m", Bookings.starttime) as month,
  Facilities.name
FROM Bookings
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid) AS subquery
GROUP BY name, month

2.6.0
2. Query all tasks
('Badminton Court', '07', 56)
('Badminton Court', '08', 146)
('Badminton Court', '09', 181)
('Massage Room 1', '07', 123)
('Massage Room 1', '08', 224)
('Massage Room 1', '09', 282)
('Massage Room 2', '07', 12)
('Massage Room 2', '08', 40)
('Massage Room 2', '09', 59)
('Pool Table', '07', 110)
('Pool Table', '08', 291)
('Pool Table', '09', 435)
('Snooker Table', '07', 75)
('Snooker Table', '08', 159)
('Snooker Table', '09', 210)
('Squash Court', '07', 75)
('Squash Court', '08', 170)
('Squash Court', '09', 195)
('Table Tennis', '07', 51)
('Table Tennis', '08', 147)
('Table Tennis', '09', 205)
('Tennis Court 1', '07', 88)
('Tennis Court 1', '08', 146)
('Tennis Court 1', '09', 174)
('Tennis Court 2', '07', 68)
('Tennis Court 2', '08', 149)
('Tennis Court 2', '09', 172)
