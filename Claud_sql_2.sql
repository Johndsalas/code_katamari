
DROP TABLE targets;

CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    salesperson TEXT,
    region TEXT,
    sale_date DATE,
    amount DECIMAL(10,2)
);

INSERT INTO Sales (sale_id, salesperson, region, sale_date, amount) VALUES
    (1, 'Alice', 'East', '2026-07-18', 271.42),
    (2, 'Alice', 'East', '2026-08-13', 618.47),
    (3, 'Bob', 'East', '2026-07-03', 120.86),
    (4, 'Alice', 'East', '2026-08-02', 521.41),
    (5, 'Bob', 'East', '2026-07-15', 414.45),
    (6, 'Carol', 'West', '2026-07-11', 588.7),
    (7, 'Dave', 'West', '2026-07-10', 250.72),
    (8, 'Carol', 'West', '2026-07-06', 365.95),
    (9, 'Dave', 'West', '2026-08-08', 285.16),
    (10, 'Bob', 'East', '2026-08-04', 187.38),
    (11, 'Carol', 'West', '2026-08-05', 305.22),
    (12, 'Carol', 'West', '2026-08-15', 148.69),
    (13, 'Bob', 'East', '2026-07-06', 698.72),
    (14, 'Bob', 'East', '2026-07-18', 417.39),
    (15, 'Carol', 'West', '2026-07-24', 348.69),
    (16, 'Carol', 'West', '2026-08-08', 544.48),
    (17, 'Alice', 'East', '2026-07-30', 365.62),
    (18, 'Bob', 'East', '2026-07-04', 260.33),
    (19, 'Bob', 'East', '2026-07-26', 287.42),
    (20, 'Bob', 'East', '2026-07-14', 558.81),
    (21, 'Dave', 'West', '2026-07-10', 285.42),
    (22, 'Bob', 'East', '2026-08-07', 399.9),
    (23, 'Dave',  'West', '2026-07-15', 798.13),
    (24, 'Bob',   'East', '2026-07-06', 629.05),
    (25, 'Alice', 'East', '2026-08-10', 211.99),
    (26, 'Carol', 'West', '2026-07-25', 367.13),
    (27, 'Dave',  'West', '2026-08-05', 702.55),
    (28, 'Alice', 'East', '2026-08-13', 719.35),
    (29, 'Dave',  'West', '2026-07-08', 305.45),
    (30, 'Bob',   'East', '2026-07-01', 767.67),
    (31, 'Carol', 'West', '2026-08-02', 738.84),
    (32, 'Carol', 'West', '2026-07-10', 361.74),
    (33, 'Alice', 'East', '2026-08-08', 326.91),
    (34, 'Alice', 'East', '2026-07-24', 715.11),
    (35, 'Carol', 'West', '2026-07-04', 268.61),
    (36, 'Alice', 'East', '2026-08-01', 671.22),
    (37, 'Alice', 'East', '2026-08-12', 432.7),
    (38, 'Bob',   'East', '2026-08-03', 710.7),
    (39, 'Carol', 'West', '2026-08-04', 628.69),
    (40, 'Bob',   'East', '2026-07-26', 796.6),
    (41, 'Dave',  'West', '2026-08-03', 416.04),
    (42, 'Alice', 'East', '2026-07-05', 336.66),
    (43, 'Alice', 'East', '2026-07-01', 149.7),
    (44, 'Alice', 'East', '2026-07-05', 733.79),
    (45, 'Carol', 'West', '2026-08-02', 266.6),
    (46, 'Carol', 'West', '2026-08-04', 192.62),
    (47, 'Carol', 'West', '2026-07-31', 665.25),
    (48, 'Alice', 'East', '2026-07-07', 561.29),
    (49, 'Dave',  'West', '2026-07-27', 426.92),
    (50, 'Alice', 'East', '2026-07-04', 381.83);

CREATE TABLE targets (
    salesperson TEXT,
    region TEXT,
    target INTEGER
);

INSERT INTO targets (salesperson, region, target) VALUES
('Alice', 'East', 5652),
('Bob', 'East', 4235),
('Carol', 'West', 6234),
('Dave', 'West', 8332);

SELECT * FROM sales;
SELECT * FROM targets;

-- sales
-- sale_id INTEGER PRIMARY KEY,
-- salesperson TEXT,
-- region TEXT,
-- sale_date DATE,
-- amount DECIMAL(10,2)

-- targets
-- salesperson TEXT,
-- region TEXT,
-- target INTEGER


-- Exercise 7
-- Join sales to targets to show each salesperson's total sales alongside
-- their target, and the percentage of target achieved
-- (total_sales / target * 100). Rank salespeople within each
-- region by percentage of target achieved.
WITH repSales as(
SELECT 
			salesperson,
			sum(amount) AS totalSales
FROM 
			sales
GROUP BY
			salesperson
ORDER BY 
			totalSales desc)
SELECT 	
		rs.salesperson,
		rs.totalSales,
		t.target,
		round((rs.totalSales / t.target),2) * 100 AS percentage_of_target_achived,
		RANK() OVER ( PARTITION BY t.region ORDER BY rs.totalSales / t.target DESC) AS regional_sales_rank
		
FROM 
		repSales rs LEFT JOIN targets t ON rs.salesperson = t.salesperson;


-- Exercise 8
-- Using a CTE, find each salesperson's total sales, then join to targets
-- to return only the salespeople who are BELOW their monthly target.
-- Include how far below target they are (target - total_sales).
WITH repSales as(
SELECT 
			salesperson,
			sum(amount) AS totalSales
FROM 
			sales
GROUP BY
			salesperson
ORDER BY 
			totalSales desc)
			
SELECT 
			rs.salesperson,
			rs.totalSales,
			t.target,
			t.target - rs.totalSales AS amountBelowTarget,
			CASE WHEN (t.target - rs.totalSales) / t.target >= .2 THEN 'Yes' -- added line to flag for coaching if target missed by 20% or more 
				 ELSE 'No' END AS flagForCoaching
FROM 
			repSales rs INNER JOIN targets t ON rs.salesperson = t.salesperson
WHERE 
			t.target - rs.totalSales > 0
ORDER BY
			amountBelowTarget;

-- Exercise 9
-- For each region, find the single sale that pushed that salesperson
-- closest to (or over) their monthly target -- i.e., using a running
-- total (window function) of each salesperson's sales ordered by date,
-- find the first sale_date where the running total meets or exceeds
-- their monthly_target. Hint: you'll need a window function for the
-- running total, then a join to targets, then a filter.

WITH runTot AS ( -- get running total for sales

SELECT 
			salesPerson,
			sum(amount) OVER (PARTITION BY salesPerson ORDER BY sale_date ASC) AS runningTotal,
			sale_date,
			sale_id
FROM 
			sales
ORDER BY 
			salesPerson, sale_date
),

TargDist AS ( -- add target row and calculate distOverTarg

SELECT 
		*,
		runningTotal - target AS distOvertarg
FROM 
		runTot INNER JOIN targets using(salesPerson)
),

achievers AS ( -- get target date for employees who achieved their target sales

SELECT 	
			salesperson,
			min(sale_date) targetDate
FROM 		
			targDist
WHERE
			distOverTarg >= 0
GROUP BY 
			salesperson
),

believers AS ( -- get target date for employees who did not achieved their target sales

SELECT 	
			salesperson,
			max(sale_date) targetDate
FROM 		
			targDist
WHERE
			salesperson NOT IN (SELECT salesperson FROM achievers)
GROUP BY 
			salesperson
)

SELECT   -- combine results from achievers and believers
		*
FROM 
		achievers
		
UNION ALL 

SELECT 
		*
FROM 
		believers;


		



















