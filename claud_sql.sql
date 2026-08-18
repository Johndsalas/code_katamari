
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

DROP TABLE targets;

CREATE TABLE targets (
    salesperson TEXT,
    region TEXT,
    monthly_target INTEGER
);

INSERT INTO targets (salesperson, region, monthly_target) VALUES
('Alice', 'East', 5652),
('Bob', 'East', 4235),
('Carol', 'West', 6234),
('Dave', 'West', 8332);


SELECT * FROM targets;

SELECT * FROM Sales;


-- Exercise 1
-- Given the sales table (sale_id, salesperson, region, sale_date, amount),
-- write a query that ranks salespeople by total sales within each region using RANK.


SELECT 
			region,
			salesperson,
			amount,
			RANK () OVER ( PARTITION BY region ORDER BY amount DESC ) AS rank_in_region
FROM 
			Sales
GROUP BY
			salesperson;
		

-- Exercise 2
-- Write a query with LAG to show each salesperson's sale amount compared to
-- their previous sale (ordered by date).

SELECT
			salesperson,
			sale_date AS current_sale_date,
			amount AS current_amount,
			LAG(sale_date) OVER (PARTITION BY salesperson ORDER BY sale_date) AS last_date,
		    LAG(amount) OVER (PARTITION BY salesperson ORDER BY sale_date) AS last_amount
FROM 
			sales
ORDER BY 
			salesperson, sale_date;
		


-- Exercise 3
-- Write a query using a CTE to first calculate each region's average sale amount,
-- then return all sales above their region's average.

WITH ave_sale_region AS (
SELECT 
			region,
			round(avg(amount),2) AS region_average
FROM
			sales
GROUP BY 
			region)
			
SELECT 
			RANK () OVER (ORDER BY amount - region_average DESC) AS sales_rank, -- added a sales rank by highest margin for fun
			sale_date,
			sale_id,
			salesperson,
			s.region,
			region_average,
			amount
			
FROM 
			sales s LEFT JOIN ave_sale_region  a ON s.region = a.region
WHERE
			amount > region_average
ORDER BY
			amount - region_average DESC;



-- Exercise 4
-- Write a correlated subquery that returns each salesperson's most recent sale date.

-- Not sure what is ment by correlated subquerry but this gets the desiered output
SELECT
			salesperson,
			max(sale_date) AS most_recent_sale
FROM
			sales
GROUP BY 
			salesperson;

-- Exercise 5
-- Write a query using ROW_NUMBER to find the top 3 highest sales per region.

WITH sales_rank AS (
SELECT 
			ROW_NUMBER () OVER ( PARTITION BY region ORDER BY amount ) AS region_sale_rank,
			region,
			sale_id,
			salesperson,
			amount
FROM 
			sales)
			
SELECT
			*
FROM 
			sales_rank
WHERE 
			region_sale_rank <= 3
ORDER BY 
			region, region_sale_rank;
		

-- Exercise 6
-- No coding needed - explain in 2-3 sentences (as a comment or out loud):
-- when would you use a window function instead of a GROUP BY?

-- Group functions perform aggrigations by condensing the number of rows gaining summary data at the cost of reduced granularity.
-- I would use these for simpler calculations where I only need the summery data and don't need to maintain the granularity of the data.
-- Window functions perform calculations across everyline of the data maintaining granularity at the cost of complicating the data 
-- as one row will not equal one observation in the calculated row. I would use window functions where I needed to display complex data patterns accross multiple 
-- rows such as comparing the average sales value accross all sales values in the data set

-- I think I have the abstract part of this question down but my answer could be better if I had better examples can you provide me with some better examples to 
-- improve my answer?

-- New table: monthly sales targets per salesperson


-- Exercise 7
-- Join sales to targets to show each salesperson's total sales alongside
-- their monthly target, and the percentage of target achieved
-- (total_sales / monthly_target * 100). Rank salespeople within each
-- region by percentage of target achieved.


-- Exercise 8
-- Using a CTE, find each salesperson's total sales, then join to targets
-- to return only the salespeople who are BELOW their monthly target.
-- Include how far below target they are (target - total_sales).


-- Exercise 9
-- For each region, find the single sale that pushed that salesperson
-- closest to (or over) their monthly target -- i.e., using a running
-- total (window function) of each salesperson's sales ordered by date,
-- find the first sale_date where the running total meets or exceeds
-- their monthly_target. Hint: you'll need a window function for the
-- running total, then a join to targets, then a filter.
-- Exercise 7
-- Join sales to targets to show each salesperson's total sales alongside
-- their monthly target, and the percentage of target achieved
-- (total_sales / monthly_target * 100). Rank salespeople within each
-- region by percentage of target achieved.


-- Exercise 8
-- Using a CTE, find each salesperson's total sales, then join to targets
-- to return only the salespeople who are BELOW their monthly target.
-- Include how far below target they are (target - total_sales).


-- Exercise 9
-- For each region, find the single sale that pushed that salesperson
-- closest to (or over) their monthly target -- i.e., using a running
-- total (window function) of each salesperson's sales ordered by date,
-- find the first sale_date where the running total meets or exceeds
-- their monthly_target. Hint: you'll need a window function for the
-- running total, then a join to targets, then a filter.


















