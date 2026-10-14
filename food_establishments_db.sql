-- Check row counts
SELECT COUNT(*)
FROM public.iowa_food_establishments;


-- Check first 10 rows
SELECT *
FROM public.iowa_food_establishments
LIMIT 10;

--Find the repeated header rows
SELECT *
FROM public.iowa_food_establishments
WHERE bottle_volume_ml = 'bottle_volume_ml'
LIMIT 10;

-- remove only the rows with repeated columns
DELETE FROM public.iowa_food_establishments
WHERE bottle_volume_ml = 'bottle_volume_ml';

-- Inspect Ordered_on column
SELECT ordered_on, COUNT(*) AS records
FROM public.iowa_food_establishments
GROUP BY ordered_on
ORDER BY records DESC
LIMIT 15;

-- Change ordered_on dtype from text to date
ALTER TABLE public.iowa_food_establishments
ALTER COLUMN ordered_on TYPE DATE
USING NULLIF(TRIM(ordered_on), '')::DATE;

-- Check date range min and max date
SELECT
    MIN(ordered_on) AS earliest_date,
    MAX(ordered_on) AS latest_date,
    COUNT(DISTINCT ordered_on) AS unique_dates
FROM public.iowa_food_establishments;

-- Check Numeric columns
SELECT
    state_bottle_cost,
    state_bottle_retail,
    sales_bottles,
    sales_dollars,
    sales_liters,
    sales_gallons
FROM public.iowa_food_establishments
LIMIT 15;


SELECT COUNT(*)
FROM public.iowa_food_establishments
WHERE ordered_on = 'ordered_on';


-- Change Numeric columns to numeric
ALTER TABLE public.iowa_food_establishments
    ALTER COLUMN pack TYPE INTEGER
        USING NULLIF(TRIM(pack), '')::INTEGER,

    ALTER COLUMN bottle_volume_ml TYPE NUMERIC
        USING NULLIF(TRIM(bottle_volume_ml), '')::NUMERIC,

    ALTER COLUMN state_bottle_cost TYPE NUMERIC(12, 2)
        USING NULLIF(TRIM(state_bottle_cost), '')::NUMERIC,

    ALTER COLUMN state_bottle_retail TYPE NUMERIC(12, 2)
        USING NULLIF(TRIM(state_bottle_retail), '')::NUMERIC,

    ALTER COLUMN sales_bottles TYPE INTEGER
        USING NULLIF(TRIM(sales_bottles), '')::INTEGER,

    ALTER COLUMN sales_dollars TYPE NUMERIC(14, 2)
        USING NULLIF(TRIM(sales_dollars), '')::NUMERIC,

    ALTER COLUMN sales_liters TYPE NUMERIC(14, 3)
        USING NULLIF(TRIM(sales_liters), '')::NUMERIC,

    ALTER COLUMN sales_gallons TYPE NUMERIC(14, 3)
        USING NULLIF(TRIM(sales_gallons), '')::NUMERIC;

-- Check first 5 rows
SELECT *
FROM public.iowa_food_establishments
LIMIT 5;

-- distinct row vs total rows
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (
        ordered_on,
        store_no,
        item_no,
        vendor_number,
        sales_bottles,
        sales_dollars
    )) AS distinct_combinations
FROM public.iowa_food_establishments;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT row(
        ordered_on,
        store_no,
        store_name,
        store_address,
        store_city,
        store_zip_code,
        county_fips_code,
        county_name,
        category_code,
        category_name,
        vendor_number,
        vendor_name,
        item_no,
        im_desc,
        pack,
        bottle_volume_ml,
        state_bottle_cost,
        state_bottle_retail,
        sales_bottles,
        sales_dollars,
        sales_liters,
        sales_gallons
    )) AS distinct_full_rows
FROM public.iowa_food_establishments;


-- Inspect the repeated rows
SELECT
    ordered_on,
    store_no,
    item_no,
    vendor_number,
    sales_bottles,
    sales_dollars,
    COUNT(*) AS occurrences
FROM public.iowa_food_establishments
GROUP BY
    ordered_on,
    store_no,
    store_name,
    store_address,
    store_city,
    store_zip_code,
    county_fips_code,
    county_name,
    category_code,
    category_name,
    vendor_number,
    vendor_name,
    item_no,
    im_desc,
    pack,
    bottle_volume_ml,
    state_bottle_cost,
    state_bottle_retail,
    sales_bottles,
    sales_dollars,
    sales_liters,
    sales_gallons
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;


-- Check whether the duplicates are inflating total sales
WITH deduplicated AS (
    SELECT DISTINCT *
    FROM public.iowa_food_establishments
)
SELECT
    'Original' AS dataset,
    COUNT(*) AS total_rows,
    ROUND(SUM(sales_dollars)::numeric, 2) AS total_sales,
    SUM(sales_bottles) AS total_bottles
FROM public.iowa_food_establishments

UNION ALL

SELECT
    'After exact deduplication' AS dataset,
    COUNT(*) AS total_rows,
    ROUND(SUM(sales_dollars)::numeric, 2) AS total_sales,
    SUM(sales_bottles) AS total_bottles
FROM deduplicated;


SELECT
    ordered_on,
    store_no,
    item_no,
    COUNT(*) AS row_count,
    COUNT(DISTINCT sales_dollars) AS distinct_sales_amounts,
    COUNT(DISTINCT sales_bottles) AS distinct_bottle_counts,
    SUM(sales_dollars) AS combined_sales,
    SUM(sales_bottles) AS combined_bottles
FROM public.iowa_food_establishments
WHERE ordered_on = '2025-10-07'
  AND store_no = '5444'
  AND item_no = '66936'
GROUP BY ordered_on, store_no, item_no;


WITH repeated_groups AS (
    SELECT
        ordered_on,
        store_no,
        item_no,
        vendor_number,
        sales_bottles,
        sales_dollars,
        COUNT(*) AS occurrences
    FROM public.iowa_food_establishments
    GROUP BY
        ordered_on,
        store_no,
        item_no,
        vendor_number,
        sales_bottles,
        sales_dollars
    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS repeated_groups,
    SUM(occurrences) AS rows_in_repeated_groups,
    SUM(occurrences - 1) AS excess_rows,
    MAX(occurrences) AS maximum_repetitions
FROM repeated_groups;


--Check for null values
SELECT column_name, null_count
FROM (
    SELECT
        COUNT(*) FILTER (WHERE ordered_on IS NULL) AS ordered_on,
        COUNT(*) FILTER (WHERE store_no IS NULL) AS store_no,
        COUNT(*) FILTER (WHERE store_name IS NULL) AS store_name,
        COUNT(*) FILTER (WHERE store_city IS NULL) AS store_city,
        COUNT(*) FILTER (WHERE county_name IS NULL) AS county_name,
        COUNT(*) FILTER (WHERE category_name IS NULL) AS category_name,
        COUNT(*) FILTER (WHERE vendor_number IS NULL) AS vendor_number,
        COUNT(*) FILTER (WHERE item_no IS NULL) AS item_no,
        COUNT(*) FILTER (WHERE im_desc IS NULL) AS im_desc,
        COUNT(*) FILTER (WHERE bottle_volume_ml IS NULL) AS bottle_volume_ml,
        COUNT(*) FILTER (WHERE state_bottle_cost IS NULL) AS state_bottle_cost,
        COUNT(*) FILTER (WHERE state_bottle_retail IS NULL) AS state_bottle_retail,
        COUNT(*) FILTER (WHERE sales_bottles IS NULL) AS sales_bottles,
        COUNT(*) FILTER (WHERE sales_dollars IS NULL) AS sales_dollars,
        COUNT(*) FILTER (WHERE sales_liters IS NULL) AS sales_liters,
        COUNT(*) FILTER (WHERE sales_gallons IS NULL) AS sales_gallons
    FROM public.iowa_food_establishments
) AS n
CROSS JOIN LATERAL (
    VALUES
        ('ordered_on', ordered_on),
        ('store_no', store_no),
        ('store_name', store_name),
        ('store_city', store_city),
        ('county_name', county_name),
        ('category_name', category_name),
        ('vendor_number', vendor_number),
        ('item_no', item_no),
        ('im_desc', im_desc),
        ('bottle_volume_ml', bottle_volume_ml),
        ('state_bottle_cost', state_bottle_cost),
        ('state_bottle_retail', state_bottle_retail),
        ('sales_bottles', sales_bottles),
        ('sales_dollars', sales_dollars),
        ('sales_liters', sales_liters),
        ('sales_gallons', sales_gallons)
) AS v(column_name, null_count)
ORDER BY null_count DESC;

-- Inspect missing records
SELECT *
FROM public.iowa_food_establishments
WHERE ordered_on IS NULL
   OR store_no IS NULL
   OR store_name IS NULL
   OR item_no IS NULL
   OR im_desc IS NULL
   OR sales_bottles IS NULL
   OR sales_dollars IS NULL
   OR sales_liters IS NULL
   OR sales_gallons IS NULL;


-- Investigate the missing prices
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE state_bottle_cost IS NULL
          AND state_bottle_retail IS NULL
    ) AS both_prices_missing,
    COUNT(*) FILTER (
        WHERE state_bottle_cost IS NULL
          AND state_bottle_retail IS NOT NULL
    ) AS cost_missing_only,
    COUNT(*) FILTER (
        WHERE state_bottle_cost IS NOT NULL
          AND state_bottle_retail IS NULL
    ) AS retail_missing_only,
    COUNT(DISTINCT item_no) FILTER (
        WHERE state_bottle_cost IS NULL
          AND state_bottle_retail IS NULL
    ) AS products_with_both_prices_missing
FROM public.iowa_food_establishments;


-- Compare total sales with duplicated 
WITH deduplicated AS (
    SELECT DISTINCT *
    FROM public.iowa_food_establishments
),
original_monthly AS (
    SELECT
        DATE_TRUNC('month', ordered_on)::DATE AS sales_month,
        SUM(sales_dollars) AS original_revenue
    FROM public.iowa_food_establishments
    GROUP BY 1
),
deduplicated_monthly AS (
    SELECT
        DATE_TRUNC('month', ordered_on)::DATE AS sales_month,
        SUM(sales_dollars) AS deduplicated_revenue
    FROM deduplicated
    GROUP BY 1
)
SELECT
    o.sales_month,
    ROUND(o.original_revenue::numeric, 2) AS original_revenue,
    ROUND(d.deduplicated_revenue::numeric, 2) AS deduplicated_revenue,
    ROUND(
        (o.original_revenue - d.deduplicated_revenue)::numeric,
        2
    ) AS revenue_difference
FROM original_monthly o
JOIN deduplicated_monthly d USING (sales_month)
ORDER BY o.sales_month;

--Investigate the September and October records
WITH deduplicated AS (
    SELECT DISTINCT *
    FROM public.iowa_food_establishments
),
original_sales AS (
    SELECT
        DATE_TRUNC('month', ordered_on)::DATE AS sales_month,
        store_no,
        store_name,
        SUM(sales_dollars) AS original_revenue
    FROM public.iowa_food_establishments
    WHERE ordered_on >= '2025-08-01'
      AND ordered_on <  '2025-11-01'
    GROUP BY 1, 2, 3
),
deduplicated_sales AS (
    SELECT
        DATE_TRUNC('month', ordered_on)::DATE AS sales_month,
        store_no,
        store_name,
        SUM(sales_dollars) AS deduplicated_revenue
    FROM deduplicated
    WHERE ordered_on >= '2025-08-01'
      AND ordered_on <  '2025-11-01'
    GROUP BY 1, 2, 3
)
SELECT
    o.sales_month,
    o.store_no,
    o.store_name,
    ROUND(o.original_revenue::numeric, 2) AS original_revenue,
    ROUND(d.deduplicated_revenue::numeric, 2) AS deduplicated_revenue,
    ROUND(
        (o.original_revenue - d.deduplicated_revenue)::numeric, 2
    ) AS revenue_difference
FROM original_sales o
JOIN deduplicated_sales d
  ON o.sales_month = d.sales_month
 AND o.store_no = d.store_no
ORDER BY revenue_difference DESC
LIMIT 20;


--which product categories generate the most revenue?
SELECT
    category_name,
    ROUND(SUM(sales_dollars)::numeric, 2) AS total_revenue,
    SUM(sales_bottles) AS bottles_sold,
    COUNT(DISTINCT item_no) AS unique_products,
    ROUND(
        100.0 * SUM(sales_dollars)
        / NULLIF(SUM(SUM(sales_dollars)) OVER (), 0),
        2
    ) AS revenue_share_pct
FROM public.iowa_food_establishments
WHERE category_name IS NOT NULL
GROUP BY category_name
ORDER BY total_revenue DESC;

-- Which products are the biggest revenue contributors?
WITH product_revenue AS (
    SELECT
        item_no,
        im_desc AS product_name,
        SUM(sales_bottles) AS bottles_sold,
        SUM(sales_dollars) AS total_revenue
    FROM public.iowa_food_establishments
    WHERE item_no IS NOT NULL
    GROUP BY item_no, im_desc
)
SELECT
    item_no,
    product_name,
    bottles_sold,
    ROUND(total_revenue::numeric, 2) AS total_revenue,
    ROUND(
        100.0 * total_revenue
        / NULLIF(SUM(total_revenue) OVER (), 0),
        2
    ) AS revenue_share_pct
FROM product_revenue
ORDER BY total_revenue DESC
LIMIT 20;

-- Which counties generate the most revenue?
SELECT
    county_name,
    ROUND(SUM(sales_dollars)::numeric, 2) AS total_revenue,
    SUM(sales_bottles) AS bottles_sold,
    COUNT(DISTINCT store_no) AS unique_stores,
    ROUND(
        SUM(sales_dollars)
        / NULLIF(COUNT(DISTINCT store_no), 0),
        2
    ) AS revenue_per_store
FROM public.iowa_food_establishments
WHERE county_name IS NOT NULL
GROUP BY county_name
ORDER BY total_revenue DESC
LIMIT 20;

-- Which stores have the highest revenue?
SELECT
    store_no,
    store_name,
    store_city,
    county_name,
    ROUND(SUM(sales_dollars)::numeric, 2) AS total_revenue,
    SUM(sales_bottles) AS bottles_sold,
    COUNT(DISTINCT item_no) AS unique_products
FROM public.iowa_food_establishments
GROUP BY
    store_no,
    store_name,
    store_city,
    county_name
ORDER BY total_revenue DESC
LIMIT 20;

--Which products sell the most bottles
--but generate relatively little revenue?
SELECT
    item_no,
    im_desc AS product_name,
    SUM(sales_bottles) AS bottles_sold,
    ROUND(SUM(sales_dollars)::numeric, 2) AS total_revenue,
    ROUND(
        SUM(sales_dollars)
        / NULLIF(SUM(sales_bottles), 0),
        2
    ) AS revenue_per_bottle
FROM public.iowa_food_establishments
WHERE item_no IS NOT NULL
GROUP BY item_no, im_desc
HAVING SUM(sales_bottles) > 0
ORDER BY bottles_sold DESC
LIMIT 20;

--How does revenue vary by day of the week?
SELECT
    EXTRACT(ISODOW FROM ordered_on)::INT AS day_number,
    TO_CHAR(ordered_on, 'FMDay') AS day_of_week,
    ROUND(SUM(sales_dollars)::numeric, 2) AS total_revenue,
    SUM(sales_bottles) AS bottles_sold,
    COUNT(*) AS total_records
FROM public.iowa_food_establishments
WHERE ordered_on IS NOT NULL
GROUP BY
    EXTRACT(ISODOW FROM ordered_on),
    TO_CHAR(ordered_on, 'FMDay')
ORDER BY day_number;


-- Which categories are growing or declining month by month?
WITH monthly_category_sales AS (
    SELECT
        DATE_TRUNC('month', ordered_on)::DATE AS sales_month,
        category_name,
        SUM(sales_dollars) AS monthly_revenue
    FROM public.iowa_food_establishments
    WHERE ordered_on IS NOT NULL
      AND category_name IS NOT NULL
    GROUP BY 1, 2
),
all_months AS (
    SELECT generate_series(
        (SELECT MIN(sales_month) FROM monthly_category_sales),
        (SELECT MAX(sales_month) FROM monthly_category_sales),
        INTERVAL '1 month'
    )::DATE AS sales_month
),
all_categories AS (
    SELECT DISTINCT category_name
    FROM monthly_category_sales
),
complete_monthly_sales AS (
    SELECT
        m.sales_month,
        c.category_name,
        COALESCE(s.monthly_revenue, 0) AS monthly_revenue
    FROM all_months m
    CROSS JOIN all_categories c
    LEFT JOIN monthly_category_sales s
        ON s.sales_month = m.sales_month
       AND s.category_name = c.category_name
),
category_trends AS (
    SELECT
        sales_month,
        category_name,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            PARTITION BY category_name
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM complete_monthly_sales
)
SELECT
    sales_month,
    category_name,
    ROUND(monthly_revenue::numeric, 2) AS monthly_revenue,
    ROUND(previous_month_revenue::numeric, 2) AS previous_month_revenue,
    ROUND(
        100.0 * (monthly_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_pct
FROM category_trends
ORDER BY sales_month, monthly_revenue DESC;

-- How concentrated is revenue among the top 10 products?
WITH product_revenue AS (
    SELECT
        item_no,
        im_desc AS product_name,
        SUM(sales_dollars) AS total_revenue
    FROM public.iowa_food_establishments
    WHERE item_no IS NOT NULL
    GROUP BY item_no, im_desc
),
ranked_products AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT
    COUNT(*) FILTER (WHERE revenue_rank <= 10) AS top_10_products,
    ROUND(
        SUM(total_revenue) FILTER (WHERE revenue_rank <= 10)::numeric,
        2
    ) AS top_10_revenue,
    ROUND(
        100.0 * SUM(total_revenue) FILTER (WHERE revenue_rank <= 10)
        / NULLIF(SUM(total_revenue), 0),
        2
    ) AS top_10_revenue_share_pct
FROM ranked_products;
