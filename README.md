# Iowa Liquor Sales Analysis

SQL business intelligence case study over 2.92 million Iowa liquor sales records from 2025.

## What it does

- Aggregates monthly revenue, category, product, county, and store performance in PostgreSQL
- Compares weekday and day-level ordering patterns
- Investigates repeated records: 429,996 exact duplicates move the revenue total by $76.75M
- Checks missing values across cost, price, and geography columns

## Files

- `iowa_food_establishments.ipynb` — analysis notebook (PostgreSQL queries plus Python charts)
- `food_establishments_db.sql` — the SQL queries behind the analysis

## Key results

- $501.56M recorded revenue across 2,920,615 rows
- September and October spikes trace to repeated records, not growth
- 41.6% of rows lack bottle cost and retail price values

## How to run

Load the source table into PostgreSQL as `public.iowa_food_establishments`, then run the notebook cells top to bottom.
