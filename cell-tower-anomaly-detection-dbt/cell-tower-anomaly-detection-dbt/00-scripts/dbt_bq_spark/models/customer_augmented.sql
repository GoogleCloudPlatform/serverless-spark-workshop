-- Copyright 2022 Google LLC.
-- SPDX-License-Identifier: Apache-2.0

{{ config(materialized='view') }}
WITH customerMasterDataFinalSubset AS (
    SELECT Index as  customerId,* EXCEPT (Index,customerID,gender,SeniorCitizen,Partner,Dependents,OnlineSecurity,OnlineBackup,DeviceProtection,TechSupport,StreamingTV,StreamingMovies,Contract,PaperlessBilling,PaymentMethod,MonthlyCharges,TotalCharges)
    FROM {{ source('spark_dataproc', 'customer_data') }} ),

serviceThresholdReferenceDataFinal AS (
    SELECT * EXCEPT (Time,Rank) FROM (SELECT  *,  ROW_NUMBER()  OVER(PARTITION BY CellName ORDER BY CellName) AS Rank
    FROM {{ source('spark_dataproc', 'service_data') }} ) where Rank=1)

SELECT * from customerMasterDataFinalSubset
INNER JOIN serviceThresholdReferenceDataFinal ON
customerMasterDataFinalSubset.CellTower = serviceThresholdReferenceDataFinal.CellName




