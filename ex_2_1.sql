-- ============================================================
-- MODULE 2 | Exercise 1: CTE Patterns
-- Difficulty: ⭐⭐ Medium  |  Estimated time: 12 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Write a basic WITH clause (CTE)
-- 2. Chain multiple CTEs together
-- 3. Understand WHY CTEs beat nested subqueries for readability
-- 4. Use CTEs to separate cleaning from aggregation
--
-- KEY CONCEPT:
-- A CTE (Common Table Expression) lets you name an intermediate
-- result and use it like a table. Think of it as a named subquery
-- that lives at the top of your SQL, not buried inside.
--
-- SYNTAX:
--   WITH cte_name AS (
--       SELECT ...
--   ),
--   another_cte AS (
--       SELECT ... FROM cte_name ...
--   )
--   SELECT * FROM another_cte;
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 1.1  Your first CTE: named intermediate result
-- ─────────────────────────────────────────────────────────────
-- Without a CTE — nested and hard to read:
SELECT customer_id, COUNT(*) AS order_count
FROM   (SELECT * FROM orders WHERE status = 'delivered') AS delivered
GROUP BY customer_id
ORDER BY order_count DESC;

-- The same query WITH a CTE — much clearer:
WITH delivered_orders AS (
    SELECT *
    FROM   orders
    WHERE  status = 'delivered'
)
SELECT customer_id, COUNT(*) AS order_count
FROM   delivered_orders
GROUP BY customer_id
ORDER BY order_count DESC;

-- ✏️  YOUR TURN:
-- Rewrite this nested query using a CTE:
--
--   SELECT category, COUNT(*) FROM
--   (SELECT * FROM products WHERE is_active = 1 AND price > 50)
--   GROUP BY category;
--
-- Name the CTE something descriptive like 'active_premium_products'.

WITH active_premium_products AS (

	SELECT 
				*
	FROM 
				products
	WHERE 
				is_active = 1
			AND price > 50
)
			
			
SELECT 
			category,
			count(*)   AS cata_count
FROM 
			active_premium_products
GROUP BY 
			category;


-- ─────────────────────────────────────────────────────────────
-- 1.2  Chaining CTEs — step by step
-- ─────────────────────────────────────────────────────────────
-- Find gold-tier customers and their total completed spend.
-- Step 1: get gold customers
-- Step 2: get their completed payments via orders
-- Step 3: sum it up

WITH gold_customers AS (
    SELECT id, first_name, last_name
    FROM   customers
    WHERE  tier = 'gold'
),
customer_payments AS (
    SELECT o.customer_id,
           SUM(p.amount) AS total_spent
    FROM   orders o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT gc.first_name,
       gc.last_name,
       COALESCE(cp.total_spent, 0) AS total_spent
FROM   gold_customers gc
LEFT JOIN customer_payments cp ON cp.customer_id = gc.id
ORDER BY total_spent DESC;

-- ✏️  YOUR TURN:
-- Build a 3-step CTE chain:
--   Step 1 (active_products):  products where is_active = 1
--   Step 2 (product_sales):    sum quantity sold per product_id
--                              (from order_items)
--   Step 3 (final SELECT):     join active_products to product_sales,
--                              show name, category, total_units_sold
--                              (use COALESCE for products with 0 sales)
-- Sort by total_units_sold DESC.

PRAGMA table_info(order_items);

WITH active_products AS (
SELECT 
		id AS product_id,
		name,
		category,
		is_active
FROM 
		products
WHERE 
		is_active = 1
),
product_sales AS (
SELECT 
			p.id               AS product_id,
			p.name             AS product_name,
			sum(oi.quantity)   AS quant_sold_per_product
FROM 
			products p LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY 
			p.id, 
			p.name
)

SELECT 
			ps.product_name,
			ap.category,
			ps.quant_sold_per_product AS total_units_sold
FROM 
		          	   active_products ap 
       		 LEFT JOIN product_sales   ps ON ap.product_id = ps.product_id
ORDER BY 
			total_units_sold DESC;


-- ─────────────────────────────────────────────────────────────
-- 1.3  CTE for clean-then-aggregate pattern
-- ─────────────────────────────────────────────────────────────
-- This is the most important production pattern: clean your data
-- FIRST in a CTE, THEN aggregate from the clean version.
-- Never mix cleaning logic and aggregation in the same SELECT.

WITH clean_customers AS (
    SELECT id,
           first_name,
           TRIM(COALESCE(email, 'unknown@shopmetrics.com')) AS email,
           CASE country
               WHEN 'US'  THEN 'United States'
               WHEN 'USA' THEN 'United States'
               ELSE COALESCE(country, 'Unknown')
           END AS country_std,
           tier
    FROM   customers
),
tier_summary AS (
    SELECT country_std,
           tier,
           COUNT(*) AS customer_count
    FROM   clean_customers
    GROUP BY country_std, tier
),
top_countries AS (
	SELECT *
	FROM tier_summary
	WHERE customer_count >= 3
)

SELECT *
FROM   top_countries
ORDER BY country_std, tier;

-- ✏️  YOUR TURN:
-- Add a third CTE called 'top_countries' that picks only countries
-- with total customer_count >= 3 (sum across all tiers).
-- Then filter tier_summary to only those top countries.
-- (Hint: you'll need to aggregate tier_summary in top_countries)



-- ─────────────────────────────────────────────────────────────
-- 1.4  CHALLENGE: Full customer report via CTEs
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Write a CTE-based query that produces one row per customer with:
--   - id, first_name, last_name
--   - clean email (TRIM, COALESCE fallback)
--   - standardized country
--   - tier
--   - total_orders (all statuses)
--   - delivered_orders (status = 'delivered' only)
--   - total_spent (completed payments only, COALESCE to 0)
-- Sort by total_spent DESC.
-- Use at least 3 CTEs.
PRAGMA table_info(payments);
SELECT DISTINCT status FROM orders; 

WITH customers_clean AS (
SELECT 
		id                                                                   AS customer_id,
		first_name,
		last_name,
		coalesce(trim(email), "nothingemail@nowhere.abyss")                  AS email,
		CASE
				WHEN country in ("US", "USA") THEN "United States"
				ELSE COALESCE(country, 'Unknown')
		END                                                                  AS country,
		tier
FROM 
		customers
),
order_status AS (
SELECT 
			customer_id,
			count(*)                                                   	   AS total_orders,
			sum(CASE WHEN status = "delivered" THEN 1 ELSE 0 END)          AS delivered_orders
FROM 
			orders
GROUP BY 
			customer_id
),
payment_status (
SELECT 
			o.customer_id,
			sum(p.amount)              AS total_spent
FROM 
			Payments p
			INNER JOIN orders o ON p.order_id =  o.id 
WHERE 
			p.status = "completed"
GROUP BY
			o.customer_id
),

SELECT 
			cc.customer_id,
			cc.first_name,
			cc.last_name,
			cc.email,
			cc.contry,
			cc.tier,
			os.total_orders,
			os.delivered_orders,
			ps.total_spent
			
FROM 
				  	  customers_clean cc
			LEFT JOIN order_status    os using(customer_id)
			LEFT JOIN payment_status  ps using(customer_id)
ORDER BY 
			total_spent DESC;
		
		
		
SELECT 
			order_id,
			sum(CASE WHEN status = "delivered" THEN amount ELSE 0 END)              AS total_spent
FROM 
			Payments
GROUP BY
			order_id