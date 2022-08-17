-- Copyright 2022 Google LLC.
-- SPDX-License-Identifier: Apache-2.0

CREATE DATABASE IF NOT EXISTS `retail_store_analytics_${username}_db`;
USE `retail_store_analytics_${username}_db`;

DROP TABLE IF EXISTS aisles;

CREATE EXTERNAL TABLE aisles (
  aisle_id STRING COMMENT 'aisle_id',
  aisle STRING COMMENT 'aisle'
) USING CSV
OPTIONS (path "gs://${bucket-name}/retail_store_analytics_metastore_sparksql/01-datasets/aisles",
        delimiter ",",
        header "true");

DROP TABLE IF EXISTS departments;

CREATE EXTERNAL TABLE departments (
  department_id STRING COMMENT 'department_id',
  department STRING COMMENT 'department'
) USING CSV
OPTIONS (path "gs://${bucket-name}/retail_store_analytics_metastore_sparksql/01-datasets/departments",
        delimiter ",",
        header "true");

DROP TABLE IF EXISTS orders;

CREATE EXTERNAL TABLE orders (
  order_id STRING COMMENT 'order_id',
  user_id STRING COMMENT 'user_id',
  eval_set STRING COMMENT 'eval_set',
  order_number STRING COMMENT 'order_number',
  order_dow STRING COMMENT 'order_dow',
  order_hour_of_day STRING COMMENT 'order_hour_of_day',
  days_since_prior_order STRING COMMENT 'days_since_prior_order'  
) USING CSV
OPTIONS (path "gs://${bucket-name}/retail_store_analytics_metastore_sparksql/01-datasets/orders",
        delimiter ",",
        header "true");

DROP TABLE IF EXISTS products;

CREATE EXTERNAL TABLE products (
  product_id STRING COMMENT 'product_id',
  product_name STRING COMMENT 'product_name',
  aisle_id STRING COMMENT 'aisle_id',
  department_id STRING COMMENT 'department_id'
) USING CSV
OPTIONS (path "gs://${bucket-name}/retail_store_analytics_metastore_sparksql/01-datasets/products",
        delimiter ",",
        header "true");

DROP TABLE IF EXISTS order_products;

CREATE EXTERNAL TABLE order_products (
  order_id STRING COMMENT 'order_id',
  product_id STRING COMMENT 'product_id',
  add_to_cart_order STRING COMMENT 'add_to_cart_order',
  reordered STRING COMMENT 'reordered'
) USING CSV
OPTIONS (path "gs://${bucket-name}/retail_store_analytics_metastore_sparksql/01-datasets/order_products",
        delimiter ",",
        header "true");


