# SQL Data Analytics Project

A SQL Server project for exploring sales data and building analytical reports with T-SQL. The scripts create a database from CSV files, explore customer, product, and sales data, and produce customer and product reports.

## Project Structure

```text
sql-data-analytics-project/
├── 00_setup/                          # Setup instructions
├── 01_datasets/
│   └── csv-files/                     # CSV files used to load the database
├── 02_docs/                            # Project documentation
├── 03_scripts/
│   ├── 00_init_database.sql            # Creates the database and loads CSV files
│   ├── 01_database_exploration.sql
│   ├── 02_dimensions_exploration.sql
│   ├── 03_date_range_exploration.sql
│   ├── 04_measures_exploration.sql
│   ├── 05_magnitude_analysis.sql
│   ├── 06_ranking_analysis.sql
│   ├── 07_change_over_time_analysis.sql
│   ├── 08_cumulative_analysis.sql
│   ├── 09_performance_analysis.sql
│   ├── 10_part_to_whole_analysis.sql
│   ├── 11_data_segmentation.sql
│   ├── 12_report_customers.sql
│   └── 13_report_products.sql
├── LICENSE
└── README.md


Getting Started
Requirements
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- The project CSV files
Create and Load the Database
1. Clone this repository.
2. Place the required CSV files in 01_datasets/csv-files/.
3. Open 03_scripts/00_init_database.sql in SSMS.
4. Update each BULK INSERT path to match where you saved the CSV files.
5. Connect to SQL Server and run the script.
Warning: The initialization script drops and recreates DataWarehouseAnalytics if that database already exists. This permanently deletes its existing data.

The script creates the gold schema and loads these tables:
- gold.dim_customers
- gold.dim_products
- gold.fact_sales
Run the Analysis Scripts
After the database is loaded, run the scripts in 03_scripts/ in numerical order. The analysis scripts query the Gold tables; the final two scripts create customer and product report views.
What the Project Covers
Exploratory Data Analysis
Scripts 01–`06` explore the database structure, dimensions, date ranges, key measures, data magnitude, and product and customer rankings.
Advanced Analytics
Scripts 07–`11` analyze changes over time, cumulative results, performance, category contribution to total sales, and customer and product segments.
Reports
- Customer report: Summarizes customer sales, orders, purchases, recency, and customer segments.
- Product report: Summarizes product sales, quantities, customers, recency, and product performance segments.
Technologies
- T-SQL (Transact-SQL)
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Git and GitHub
