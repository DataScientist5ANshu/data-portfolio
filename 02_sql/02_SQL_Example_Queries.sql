-- Airline & Campus Database: example queries (SQLite)
-- Tables: baggage_cases, irop_events, tour_log, guest_query_log
-- All data is simulated for practice.

-- 1. Baggage cases closed on time, by issue type
SELECT Issue_Type, COUNT(*) AS cases,
       ROUND(100.0 * AVG(Closed_On_Time), 1) AS on_time_pct,
       ROUND(AVG(Days_To_Close), 1) AS avg_days_to_close
FROM baggage_cases
GROUP BY Issue_Type
ORDER BY on_time_pct;

-- 2. Does finding the bag at the first station change closure time?
SELECT CASE WHEN Found_At_First_Station = 1 THEN 'Found at first station' ELSE 'Not found at first station' END AS scenario,
       COUNT(*) AS cases,
       ROUND(AVG(Days_To_Close), 2) AS avg_days,
       ROUND(100.0 * AVG(Closed_On_Time), 1) AS on_time_pct
FROM baggage_cases
GROUP BY scenario;

-- 3. Peak-month effect on late cases
SELECT Peak_Month, COUNT(*) AS cases,
       ROUND(100.0 * (1 - AVG(Closed_On_Time)), 1) AS late_pct
FROM baggage_cases
GROUP BY Peak_Month;

-- 4. Compensation paid per year
SELECT strftime('%Y', Report_Date) AS year,
       COUNT(*) AS cases,
       SUM(Compensation_INR) AS total_compensation_inr
FROM baggage_cases
GROUP BY year
ORDER BY year;

-- 5. Which disruption types generate the most complaints per affected passenger?
SELECT Disruption_Type, COUNT(*) AS events,
       SUM(Passengers_Affected) AS pax_affected,
       ROUND(1.0 * SUM(Complaints_Logged) / SUM(Passengers_Affected), 3) AS complaints_per_pax,
       ROUND(AVG(Avg_Wait_Minutes), 0) AS avg_wait_min
FROM irop_events
GROUP BY Disruption_Type
ORDER BY complaints_per_pax DESC;

-- 6. Disruptions by month of year (fog and monsoon seasons)
SELECT CAST(strftime('%m', Event_Date) AS INTEGER) AS month, COUNT(*) AS events
FROM irop_events
GROUP BY month
ORDER BY month;

-- 7. Window function: running total of passengers affected per year
SELECT Event_Date, Disruption_Type, Passengers_Affected,
       SUM(Passengers_Affected) OVER (PARTITION BY strftime('%Y', Event_Date) ORDER BY Event_Date, Event_ID) AS running_pax_year
FROM irop_events
ORDER BY Event_Date;

-- 8. Top 3 worst disruption events per cause (by wait time)
SELECT * FROM (
  SELECT Event_ID, Cause, Event_Date, Avg_Wait_Minutes,
         RANK() OVER (PARTITION BY Cause ORDER BY Avg_Wait_Minutes DESC) AS rnk
  FROM irop_events
) WHERE rnk <= 3;

-- 9. Guest desk: SLA breach rate by category
SELECT Category, COUNT(*) AS queries,
       ROUND(100.0 * SUM(SLA_Breached) / COUNT(*), 1) AS breach_pct
FROM guest_query_log
GROUP BY Category
ORDER BY breach_pct DESC;

-- 10. Tours: satisfaction with vs without a KISS stop
SELECT CASE WHEN Campuses_Covered LIKE '%KISS%' THEN 'Includes KISS' ELSE 'No KISS stop' END AS itinerary,
       COUNT(*) AS tours, ROUND(AVG(Satisfaction_Score), 2) AS avg_satisfaction
FROM tour_log
GROUP BY itinerary;

-- 11. Join across years: disruption months vs baggage case months
SELECT b.month, b.baggage_cases, i.disruptions
FROM (SELECT strftime('%Y-%m', Report_Date) AS month, COUNT(*) AS baggage_cases FROM baggage_cases GROUP BY month) b
JOIN (SELECT strftime('%Y-%m', Event_Date) AS month, COUNT(*) AS disruptions FROM irop_events GROUP BY month) i
  ON b.month = i.month
ORDER BY b.month;
