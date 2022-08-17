-- Copyright 2022 Google LLC.
-- SPDX-License-Identifier: Apache-2.0

USE `retail_store_analytics_${username}_db`;

SHOW TABLES FROM `retail_store_analytics_${username}_db`;

CREATE TEMPORARY VIEW order_products_orders AS select o.*,op.product_id,op.add_to_cart_order,op.reordered from order_products op inner join orders o on op.order_id =o.order_id;

CREATE TEMPORARY VIEW products_aisles_departments AS select p.*,a.aisle,d.department from products p inner join aisles a on p.aisle_id=a.aisle_id inner join departments d on p.department_id=d.department_id;

CREATE TEMPORARY VIEW final_join AS select o.*,p.product_name,p.aisle_id,p.department_id,p.aisle,p.department from order_products_orders o inner join products_aisles_departments p on o.product_id=p.product_id;

CREATE TEMPORARY VIEW sales_per_dow_per_departmentproduct AS select distinct department,product_id,aisle,aisle_id,order_dow,SUM(add_to_cart_order) OVER (PARTITION BY order_dow,department,product_id) AS sales_per_dow_per_departmentproduct FROM final_join;

CREATE TEMPORARY VIEW average_sales AS select ss.*,AVG(sales_per_dow_per_departmentproduct) OVER (PARTITION BY product_id) AS avg_sales FROM sales_per_dow_per_departmentproduct SS;

CREATE TEMPORARY VIEW inventory AS select ASE.*,round(avg_sales-sales_per_dow_per_departmentproduct) AS inventory from average_sales ASE;

select * from inventory where product_id=27845;



