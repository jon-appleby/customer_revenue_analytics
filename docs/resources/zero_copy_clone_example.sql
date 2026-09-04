-- Zero-copy cloning examples:
-- 1- Cloning a table, then confirm the clone is a separate full copy
-- 2- Copy of an entire schema for building on a separate schema without touching ANALYTICS
-- 3- Modifying data of cloned copy leaves source unchanged
-- 4- Clone from a previous point in time

USE ROLE DBT_DEV_ROLE;
USE DATABASE OLIST_ANALYTICS;


-- Clone a single table
CREATE OR REPLACE TRANSIENT TABLE ANALYTICS.FCT_ORDER_ITEMS_CLONE
    CLONE ANALYTICS.FCT_ORDER_ITEMS;

SELECT
    'source' AS object_name,
    COUNT(*) AS row_count,
    ROUND(SUM(item_total_revenue), 2) AS total_revenue
FROM ANALYTICS.FCT_ORDER_ITEMS

UNION ALL

SELECT
    'clone' AS object_name,
    COUNT(*) AS row_count,
    ROUND(SUM(item_total_revenue), 2) AS total_revenue
FROM ANALYTICS.FCT_ORDER_ITEMS_CLONE;


-- Clone entire schema as a dev environment
CREATE OR REPLACE SCHEMA DEV_CLONE
    CLONE ANALYTICS;

SHOW TABLES IN SCHEMA DEV_CLONE;


-- Deleting from clone
DELETE FROM DEV_CLONE.FCT_ORDER_ITEMS
WHERE order_status = 'canceled';

SELECT
    (SELECT COUNT(*) FROM ANALYTICS.FCT_ORDER_ITEMS)  AS source_rows,
    (SELECT COUNT(*) FROM DEV_CLONE.FCT_ORDER_ITEMS)  AS clone_rows;


-- Clone as of a past point in time
CREATE OR REPLACE TRANSIENT TABLE ANALYTICS.FCT_ORDER_ITEMS_PREV
    CLONE ANALYTICS.FCT_ORDER_ITEMS
    AT (OFFSET => -60 * 30); -- 30 mins ago


DROP TABLE IF EXISTS ANALYTICS.FCT_ORDER_ITEMS_CLONE;
DROP TABLE IF EXISTS ANALYTICS.FCT_ORDER_ITEMS_PREV;
DROP SCHEMA IF EXISTS DEV_CLONE;