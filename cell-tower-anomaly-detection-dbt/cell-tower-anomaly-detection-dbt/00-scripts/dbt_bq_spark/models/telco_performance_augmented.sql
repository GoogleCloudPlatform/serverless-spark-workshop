-- Copyright 2022 Google LLC.
-- SPDX-License-Identifier: Apache-2.0

{{ config(materialized='view') }}
WITH telecomCustomerChurnFinal AS (
    SELECT roam_Mean,change_mou,drop_vce_Mean,drop_dat_Mean,blck_vce_Mean,blck_dat_Mean,plcd_vce_Mean,plcd_dat_Mean,comp_vce_Mean,comp_dat_Mean,peak_vce_Mean,peak_dat_Mean,mou_peav_Mean,mou_pead_Mean,opk_vce_Mean,opk_dat_Mean,mou_opkv_Mean,mou_opkd_Mean,drop_blk_Mean,callfwdv_Mean,callwait_Mean,churn,months,uniqsubs,actvsubs,area,dualband,forgntvl, CAST(SUBSTR(CAST(Customer_ID AS STRING), 4,7) AS INT64) as Customer_ID
    FROM {{ source('spark_dataproc', 'telecom_data') }} )
SELECT * EXCEPT (churn,Customer_ID)
FROM telecomCustomerChurnFinal INNER JOIN {{ ref('customer_augmented') }} customer_augmented ON
customer_augmented.customerID = telecomCustomerChurnFinal.Customer_ID
