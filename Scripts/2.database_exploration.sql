/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    Explore the database structure, including schemas, tables, and column
    definitions.

Tables and Views Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

USE DataWarehouseAnalytics;
GO

-- Retrieve a list of tables and views in the database
SELECT
    TABLE_CATALOG AS database_name,
    TABLE_SCHEMA AS schema_name,
    TABLE_NAME AS object_name,
    TABLE_TYPE AS object_type
FROM INFORMATION_SCHEMA.TABLES
ORDER BY
    TABLE_SCHEMA,
    TABLE_NAME;
GO

-- Retrieve column definitions for all tables and views
SELECT
    TABLE_SCHEMA AS schema_name,
    TABLE_NAME AS object_name,
    ORDINAL_POSITION AS column_position,
    COLUMN_NAME AS column_name,
    DATA_TYPE AS data_type,
    IS_NULLABLE AS is_nullable,
    CHARACTER_MAXIMUM_LENGTH AS max_length,
    NUMERIC_PRECISION AS numeric_precision,
    NUMERIC_SCALE AS numeric_scale
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY
    TABLE_SCHEMA,
    TABLE_NAME,
    ORDINAL_POSITION;
GO

-- Retrieve column definitions for a specific table
SELECT
    COLUMN_NAME AS column_name,
    DATA_TYPE AS data_type,
    IS_NULLABLE AS is_nullable,
    CHARACTER_MAXIMUM_LENGTH AS max_length,
    NUMERIC_PRECISION AS numeric_precision,
    NUMERIC_SCALE AS numeric_scale
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
  AND TABLE_NAME = 'dim_customers'
ORDER BY ORDINAL_POSITION;
GO
