# Apple Products Pricing Analysis (2020–2026)

End-to-end data analytics project covering data cleaning, exploratory analysis, SQL querying, and an interactive Power BI dashboard, built on an 80,000-row dataset of Apple product listings (iPhone, iPad, Mac, Watch) scraped from Amazon and Flipkart between 2020 and 2026.

## Tools Used
- **Python** (Pandas, NumPy) — data cleaning and EDA
- **MySQL** — data storage and querying (basic to advanced: joins, window functions, correlated subqueries)
- **Power BI** — interactive dashboard and data visualization

## Project Workflow

### 1. Data Cleaning (Python)
- Loaded and inspected an 80,000-row, 14-column dataset
- Standardized column names to snake_case
- Fixed data entry errors (e.g. "Referbished" → "Refurbished")
- Handled missing values in `sale_event` (~91.7% null, filled as "No Sale")
- Stripped whitespace inconsistencies in categorical fields
- Verified no duplicate rows or invalid price values

### 2. Exploratory Data Analysis (Python)
- Univariate analysis: price, discount, and rating distributions
- Bivariate analysis: price trends over time, average discount by platform/sale event
- Correlation analysis across price, discount, rating, and review count
- Outlier detection via IQR method (confirmed as genuine high-value products, not data errors)

### 3. SQL Analysis (MySQL)
Loaded the cleaned dataset into MySQL and wrote queries spanning:
- Basic aggregation and filtering (`GROUP BY`, `WHERE`)
- Intermediate analysis (top-N rankings, monthly trends)
- Window functions (`RANK()`, `DENSE_RANK()`, `LAG()`) for month-over-month price change and per-category rankings
- Correlated subqueries and `EXISTS` for row-level comparisons against group averages

### 4. Power BI Dashboard
A 2-page interactive dashboard:

**Page 1 — Overview**
- KPI cards: total listings, average price, average discount
- Price trend over time (2020–2026)
- Average price by product category
- Average discount by category (donut chart)
- Model-level slicer for drill-down

**Page 2 — Platform & Sales Analysis**
- Average price and discount by platform (Amazon vs Flipkart)
- Average discount by sale event (Black Friday, Prime Day, Big Billion Days, etc.)
- Stock status breakdown (In Stock / Out of Stock / Low Stock)

## Key Insights
- Average product price across the dataset: **$782.77**
- Average discount across all listings: **21.42%**, rising to **28.67%** during active sale events
- Big Billion Days and Black Friday consistently produced the largest discounts
- Price and discount show a moderate negative correlation (-0.57); rating is largely independent of price and discount
- Amazon and Flipkart show nearly identical pricing and discount behavior for the same products

## Files
- `clean_data.py` — data cleaning script
- `apple_pricing_cleaned.csv` — cleaned dataset
- `apple_pricing_queries.sql` — full set of SQL analysis queries
- Power BI `.pbix` — dashboard file
