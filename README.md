# Online Store Returns Analysis (SQL)

## About this project

This is a **practice project (trial assignment)**.

- **The task was set up with AI:** an AI assistant generated a synthetic dataset of an online store (orders and customers) with a **hidden anomaly**. The data is fake and was created only for this exercise.
- **My task:** analyse the data with SQL, **find the anomaly** and **explain what it depends on**.
- **Testing:** the queries were tested in **PostgreSQL**.


## The question

Why did the share of returned orders grow from 5.1% in August to 12.5% in September?

## How the anomaly was found

1. **Data quality check:** 40 duplicate orders and 61 NULL amounts. Duplicates were removed in a `clean` view; NULL amounts do not affect the return rate (it is calculated from `status`).
2. **Return rate by month:** 5.1% in August vs 12.5% in September. The anomaly is visible, but the cause is unknown.
3. **Return rate by carrier:** NovaPost 5.1%, UkrPost 5.1%, FastShip 19.9%. Only one carrier stands out.
4. **Carrier x month:** FastShip was normal in August (6.0%) and jumped in September (33.9%). The other carriers did not change.
5. **Other causes ruled out:** without FastShip, the return rate is 4-7% in every city and 4-6% in every product category.

## What was different

| Carrier | August | September |
|---|---|---|
| FastShip | 6.0% | **33.9%** |
| NovaPost | 4.8% | 5.4% |
| UkrPost | 5.1% | 5.1% |

## Conclusion

**The anomaly is caused by one delivery carrier, FastShip.** Its return rate grew from 6.0% (August) to 33.9% (September), while NovaPost (5.4%) and UkrPost (5.1%) did not change.

| Metric | Value |
|---|---|
| Total returns in September | 307 out of 2,449 orders |
| Of them, via FastShip | 209 (68%), although FastShip delivers only ~25% of orders |
| Excess returns caused by FastShip | ~170 (209 actual vs ~37 at the normal rate of ~6%) |
| Value of returned FastShip orders in September | ~244k (conventional units) |

**Recommendations**

1. Temporarily reduce the share of orders shipped via FastShip, or pause the cooperation.
2. Ask FastShip what changed on 1 September (delivery times, packaging, handling).
3. Analyse return reasons, if customer comments are available.
4. Set up a weekly check of return rate by carrier.

**Limitations**

- The data is synthetic; the problem was planted by the generator, so this is a demonstration of the method, not a real discovery.
- The data shows **where** the problem is, but not **why** (return reasons are not recorded).
- Only two months of data, so seasonality was not checked.

## Project structure

| File                | Purpose |
|---------------------|---|
| AI-generated synthetic data| `customers.csv` (800 rows) and `orders.csv` (5,040 rows including duplicates) |
| `queries.sql`       | 6 SQL queries for PostgreSQL (COUNT, GROUP BY, JOIN, VIEW, UNION ALL) |

## Tools

SQL (PostgreSQL), AI assistant for data generation

## What I Practiced

- Writing SQL aggregations (`COUNT`, `SUM`, `ROUND`) and conditional logic with `CASE WHEN` to calculate return rates
- Grouping and slicing data with `GROUP BY` by month, carrier, city and category
- Combining tables with `JOIN` and result sets with `UNION ALL`
- Building a reusable "clean" layer with a `VIEW` (deduplication with `DISTINCT ON`)
- Checking data quality: finding duplicates and NULL values and deciding how they affect the analysis
- Finding an anomaly step by step: from overall trend to the specific segment, then ruling out alternative causes
- Interpreting results and writing a short conclusion with recommendations