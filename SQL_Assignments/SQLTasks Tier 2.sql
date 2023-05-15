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

Answer: SELECT name FROM `Facilities` WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

Answer: select count(*) as free_for_members from Facilities where membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND membercost < monthlymaintenance * 0.2

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE name LIKE '% 2'

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
  monthlymaintenance,
     CASE 
        WHEN monthlymaintenance > 100 THEN 'expensive'
        ELSE 'cheap'
     END as maintenance_cost
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM Members

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT 
    name as court_name,
    CONCAT(firstname, ' ', surname) as full_name
FROM Members
JOIN Bookings
    ON Members.memid = Bookings.memid
JOIN Facilities
    ON Bookings.facid = Facilities.facid
    AND (Facilities.facid = 0 OR Facilities.facid = 1)
ORDER BY full_name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name, 
   CONCAT(firstname, ' ', surname) as full_name,
   CASE
       WHEN Bookings.memid = 0 THEN Facilities.guestcost * slots
       ELSE Facilities.membercost * slots
   END as cost
FROM Bookings
JOIN Members
    ON Bookings.memid = Members.memid
JOIN Facilities
    ON Bookings.facid = Facilities.facid
WHERE Bookings.starttime LIKE '2012-09-14%'
AND (
    (Bookings.memid = 0 AND Facilities.guestcost * slots > 30)
    OR (Bookings.memid != 0 AND Facilities.membercost * slots > 30)
)
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT name, 
   CONCAT(firstname, ' ', surname) as full_name,
   booking_cost
FROM (
   SELECT 
       name,
       firstname,
       surname,
       (
           CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
           ELSE Facilities.membercost * slots
           END
       ) as booking_cost
   FROM Bookings
   JOIN Members
        ON Bookings.memid = Members.memid
        JOIN Facilities
            ON Bookings.facid = Facilities.facid
        WHERE Bookings.starttime LIKE '2012-09-14%'
      ) as Expensive_Bookings
WHERE booking_cost > 30
ORDER BY booking_cost DESC

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

'''SELECT name, total_revenue
    FROM
    (SELECT name, sum(revenue) AS total_revenue
    From(
        SELECT name,
        CASE WHEN memid = 0 
            THEN guestcost * slots
        ELSE 
            membercost * slots END AS revenue
        FROM Bookings
        LEFT JOIN Facilities
        USING (facid)
        ) AS innerquery
    GROUP BY name) AS outersubquery
    WHERE total_revenue < 1000
    ORDER BY total_revenue'''

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

'''SELECT m1.surname, m1.firstname,
    m2.surname AS recommendedby_surname,
    m2.firstname AS recommendedby_firstname
    FROM Members m1
    LEFT JOIN Members as m2
    ON m1.recommendedby = m2.memid
    WHERE m1.recommendedby != 0
    ORDER BY m1.surname, m1.firstname'''

/* Q12: Find the facilities with their usage by member, but not guests */

'''SELECT name AS facility, count(memid) AS usage_by_members
    FROM Bookings as b
    INNER JOIN Facilities as f
    USING (facid)
    WHERE b.memid <> 0
    GROUP BY b.facid'''

/* Q13: Find the facilities usage by month, but not guests */

''' SELECT name AS facilities,
    strftime('%m', starttime) AS month,
    COUNT(memid) AS monthly_usage
    FROM Bookings AS b
    INNER JOIN Facilities as f
    USING (facid)
    WHERE memid <> 0
    GROUP BY facid, month'''