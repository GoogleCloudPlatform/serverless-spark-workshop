# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 

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




