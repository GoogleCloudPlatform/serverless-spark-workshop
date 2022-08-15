#!/bin/sh
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# shellcheck disable=SC2006
# shellcheck disable=SC2086
# shellcheck disable=SC2181
# shellcheck disable=SC2129

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} cell-tower-anomly-detection-dbt infrastructure destruction - Starting  .."

if [ "${#}" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage: ${0} <VARIABLES_FILE>"
    echo "Example: ${0} variables.json"
    exit 1
fi


BASE_DIR="${PWD}"/..
CONFIG_DIR="${BASE_DIR}"/02-config

PLAT=`uname`
if [ ! "${PLAT}" = "Linux" ]; then
   echo "This script needs to be executed on Linux"
   exit 1
fi



LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Checking binaries .."

GCLOUD_BIN=`which gcloud`
if [ ! "${?}" -eq 0 ];then
    LOG_DATE=`date`
    echo "gcloud not found! Please install first and configure Google Cloud SDK"
    exit 1
fi

TERRAFORM_BIN=`which terraform`
if [ ! "${?}" -eq 0 ];then
    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} Installing terraform .."
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform

    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} Terraform deployed OK"
fi

JQ_BIN=`which jq`
if [ ! "${?}" -eq 0 ];then
    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} Installing jq .."
    sudo apt-get install jq
    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} jq deployed OK"
fi

CONFIG_FILE="${1}"
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Unable to find ${CONFIG_FILE}"
    exit 1
fi

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Reading config file  ${CONFIG_FILE}.."

export PROJECT_ID=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.project_id'`
if [ -z "${PROJECT_ID}" ]
then
      echo "Error reading PROJECT_ID"
      exit 1
else
    echo "PROJECT : ${PROJECT_ID}"
fi

export REGION=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.region'`
if [ -z "${REGION}" ]
then
      echo "Error reading REGION"
      exit 1
else
    echo "REGION : ${REGION}"
fi

export BUCKET_NAME=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.bucket_name'`
if [ -z "${BUCKET_NAME}" ]
then
      echo "Error reading BUCKET_NAME"
      exit 1
else
    echo "BUCKET_NAME : ${BUCKET_NAME}"
fi
export DATAPROC_CLUSTER_NAME=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.dataproc_cluster_name'`
if [ -z "${DATAPROC_CLUSTER_NAME}" ]
then
      echo "Error reading DATAPROC_CLUSTER_NAME"
      exit 1
else
    echo "DATAPROC_CLUSTER_NAME : ${DATAPROC_CLUSTER_NAME}"
fi

export BQ_DATASET_NAME=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.bq_dataset_name'`
if [ -z "${BQ_DATASET_NAME}" ]
then
      echo "Error reading BQ_DATASET_NAME"
      exit 1
else
    echo "BQ_DATASET_NAME : ${BQ_DATASET_NAME}"
fi

export TERRAFORM_SA_NAME=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.terraform_sa_name'`
if [ -z "${TERRAFORM_SA_NAME}" ]
then
      echo "Error reading TERRAFORM_SA_NAME"
      exit 1
else
    echo "TERRAFORM_SA_NAME : ${TERRAFORM_SA_NAME}"
fi

export TERRAFORM_KEY_LOCATION=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.terraform_key_location'`
if [ -z "${TERRAFORM_KEY_LOCATION}" ]
then
      echo "Error reading TERRAFORM_KEY_LOCATION"
      exit 1
else
    echo "TERRAFORM_KEY_LOCATION : ${CONFIG_DIR}/${TERRAFORM_KEY_LOCATION}"
fi

export TF_VAR_project_id="${PROJECT_ID}"
export TF_VAR_region="${REGION}"
export TF_VAR_terraform_key_location="${CONFIG_DIR}"/"${TERRAFORM_KEY_LOCATION}"
export TF_VAR_dataproc_cluster_name="${DATAPROC_CLUSTER_NAME}"
export TF_VAR_bucket_name="${BUCKET_NAME}"
export TF_VAR_bq_dataset_name="${BQ_DATASET_NAME}"

TARGET=gs://"${BUCKET_NAME}"/data/

export TF_VAR_customer_data_gcs_uri="${TARGET}"*.parquet
export TF_VAR_service_data_gcs_uri="${TARGET}"service_threshold_data.csv
export TF_VAR_telecom_data_gcs_uri="${TARGET}"telecom_customer_churn_data.csv


echo "TF var project_id : ${PROJECT_ID}"
echo "TF var region : ${REGION}"
echo "TF var terraform_key_location : ${CONFIG_DIR}/${TERRAFORM_KEY_LOCATION}"
echo "TF var dataproc_cluster_name : ${DATAPROC_CLUSTER_NAME}"
echo "TF var bucket_name : ${BUCKET_NAME}"
echo "TF var bq_dataset_name : ${BQ_DATASET_NAME}"



TF_CORE_DIR="${CONFIG_DIR}"/tf_core
TF_DATA_DIR="${CONFIG_DIR}"/tf_data

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Destroying Terraform core ..."
cd ${TF_CORE_DIR}
export PLAN_NAME_CORE="spark-workshop-dbt-infra-core.plan"
"${TERRAFORM_BIN}" destroy

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Destroying Terraform data ..."
cd "${TF_DATA_DIR}"
export PLAN_NAME_DATA="spark-workshop-dbt-infra-data.plan"
"${TERRAFORM_BIN}" destroy

echo "${LOG_DATE} Deleting SA  ..."
"${GCLOUD_BIN}" iam service-accounts delete --quiet "${TERRAFORM_SA_NAME}"@"${PROJECT_ID}".iam.gserviceaccount.com

echo "${LOG_DATE} Deleting  SA key  ..."
if [ -f "${TERRAFORM_KEY_LOCATION}" ]; then
    LOG_DATE=`date`
    echo "${LOG_DATE} ${TERRAFORM_KEY_LOCATION} exists."
    rm "${TERRAFORM_KEY_LOCATION}"
fi



LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Execution finished! ..."
