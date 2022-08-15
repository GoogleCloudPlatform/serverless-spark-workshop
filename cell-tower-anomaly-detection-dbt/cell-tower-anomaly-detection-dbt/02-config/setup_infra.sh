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
echo "${LOG_DATE} cell-tower-anomly-detection-dbt infrastructure deployment - Starting  .."

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage: ${0} <VARIABLES_FILE>"
    echo "Example: ${0} variables.json"
    exit 1
fi

BASE_DIR=${PWD}/..
SCRIPTS_DIR=${BASE_DIR}/00-scripts
DATA_DIR=${BASE_DIR}/01-datasets
CONFIG_DIR=${BASE_DIR}/02-config

PLAT=`uname`
if [ ! "${PLAT}" = "Linux" ]; then
   echo "This script needs to be executed on Linux"
   exit 1
fi

timeout -k 2 2 bash -c "sudo chmod --help" > /dev/null 2>&1 &
if [ ! $? -eq 0 ];then
    echo "This script needs sudo access"
    exit 1
fi

CURL_BIN=`which curl`
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "curl not found!"
    exit 1
fi

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Checking binaries .."


TERRAFORM_BIN=`which terraform`
if [ ! $? -eq 0 ];then
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
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} Installing jq .."
    sudo apt-get install jq
    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} jq deployed OK"
fi


GCLOUD_BIN=`which gcloud`
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "gcloud not found! Please install first and configure Google Cloud SDK"
    exit 1
fi

GSUTIL_BIN=`which gsutil`
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "gsutil not found! Please install first and configure Google Cloud SDK"
    exit 1
fi


PIP_BIN=`which pip3`
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "pip3 not found! Please install first"
    exit 1
fi

DBT_BIN=`which dbt`
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} Installing dbt .."
    pip3 install dbt-bigquery==1.3.0b1
    #As per [CT-255] [Bug] ImportError: cannot import name soft_unicode from markupsafe (https://github.com/dbt-labs/dbt-core/issues/4745)
    pip3 install --force-reinstall MarkupSafe==2.0.1
    LOG_DATE=`date`
    echo "#################################################################"
    echo "${LOG_DATE} dbt deployed OK"
fi

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Installing extra packages.."



PIP_PACKAGES="google-cloud-dataproc google-cloud-storage"
for PIP_PACKAGE in ${PIP_PACKAGES}
do
  LOG_DATE=`date`
  echo "${LOG_DATE} Deploying PIP package ..  ${PIP_PACKAGE}"
  ${PIP_BIN} install ${PIP_PACKAGE}
  if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "Unable to run  ${PIP_BIN} install ${PIP_PACKAGE}"
    exit 1
  fi
done

CONFIG_FILE=${1}
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Unable to find ${CONFIG_FILE}"
    exit 1
fi

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Reading config file  ${CONFIG_FILE}.."

export PROJECT_ID=`cat ${CONFIG_FILE} | ${JQ_BIN} -r '.project_id'`
if [ -z ${PROJECT_ID} ]
then
      echo "Error reading PROJECT_ID"
      exit 1
else
    echo "PROJECT : ${PROJECT_ID}"
fi

export REGION=`cat ${CONFIG_FILE} | ${JQ_BIN} -r '.region'`
if [ -z ${REGION} ]
then
      echo "Error reading REGION"
      exit 1
else
    echo "REGION : ${REGION}"
fi

export BUCKET_NAME=`cat ${CONFIG_FILE} | ${JQ_BIN} -r '.bucket_name'`
if [ -z ${BUCKET_NAME} ]
then
      echo "Error reading BUCKET_NAME"
      exit 1
else
    echo "BUCKET_NAME : ${BUCKET_NAME}"
fi
export DATAPROC_CLUSTER_NAME=`cat ${CONFIG_FILE} | ${JQ_BIN} -r '.dataproc_cluster_name'`
if [ -z ${DATAPROC_CLUSTER_NAME} ]
then
      echo "Error reading DATAPROC_CLUSTER_NAME"
      exit 1
else
    echo "DATAPROC_CLUSTER_NAME : ${DATAPROC_CLUSTER_NAME}"
fi

export BQ_DATASET_NAME=`cat ${CONFIG_FILE} | ${JQ_BIN} -r '.bq_dataset_name'`
if [ -z ${BQ_DATASET_NAME} ]
then
      echo "Error reading BQ_DATASET_NAME"
      exit 1
else
    echo "BQ_DATASET_NAME : ${BQ_DATASET_NAME}"
fi

export TERRAFORM_SA_NAME=`cat ${CONFIG_FILE} | ${JQ_BIN} -r '.terraform_sa_name'`
if [ -z ${TERRAFORM_SA_NAME} ]
then
      echo "Error reading TERRAFORM_SA_NAME"
      exit 1
else
    echo "TERRAFORM_SA_NAME : ${TERRAFORM_SA_NAME}"
fi

export TERRAFORM_KEY_LOCATION=`cat ${CONFIG_FILE} | ${JQ_BIN} -r '.terraform_key_location'`
if [ -z ${TERRAFORM_KEY_LOCATION} ]
then
      echo "Error reading TERRAFORM_KEY_LOCATION"
      exit 1
else
    echo "TERRAFORM_KEY_LOCATION : ${PWD}/${TERRAFORM_KEY_LOCATION}"
fi

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Enabling Project APIs ..."
${GCLOUD_BIN} config set project ${PROJECT_ID}
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "Unable to run ${GCLOUD_BIN} config set project ${PROJECT_ID}"
    exit 1
fi
PROJECT_APIS_LIST="compute.googleapis.com dataproc.googleapis.com bigquery.googleapis.com storage-api.googleapis.com iam.googleapis.com  iamcredentials.googleapis.com"
for API_NAME in ${PROJECT_APIS_LIST}
do
  LOG_DATE=`date`
  echo "${LOG_DATE} Enabling API .. " ${API_NAME}
  ${GCLOUD_BIN} services enable ${API_NAME}
  if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "Unable to run  ${GCLOUD_BIN} services enable ${API_NAME}"
    exit 1
  fi
done

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Creating Service Accounts ..."
${GCLOUD_BIN} iam service-accounts describe ${TERRAFORM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
if [ $? -eq 0 ]; then
    LOG_DATE=`date`
    echo "${LOG_DATE} Service account ${TERRAFORM_SA_NAME} already exists, recreating it ..."
    ${GCLOUD_BIN} iam service-accounts delete --quiet ${TERRAFORM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
    if [ ! $? -eq 0 ];then
      LOG_DATE=`date`
      echo "Unable to run ${GCLOUD_BIN} iam service-accounts delete --quiet ${TERRAFORM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com}"
      exit 1
    fi
    ${GCLOUD_BIN} iam service-accounts create ${TERRAFORM_SA_NAME}
    if [ ! $? -eq 0 ];then
      LOG_DATE=`date`
      echo "Unable to run ${GCLOUD_BIN} iam service-accounts create ${TERRAFORM_SA_NAME}"
      exit 1
    fi
else
    LOG_DATE=`date`
    echo "${LOG_DATE} Creating Service Account .. " ${TERRAFORM_SA_NAME}
    ${GCLOUD_BIN} iam service-accounts create ${TERRAFORM_SA_NAME}
    if [ ! $? -eq 0 ];then
      LOG_DATE=`date`
      echo "Unable to run ${GCLOUD_BIN} iam service-accounts create ${TERRAFORM_SA_NAME}"
      exit 1
    fi
fi
TF_SA_ROLES_LIST="roles/bigquery.admin roles/dataproc.admin roles/compute.admin  roles/resourcemanager.projectIamAdmin roles/iam.securityAdmin roles/iam.serviceAccountAdmin roles/iam.serviceAccountUser roles/servicenetworking.networksAdmin roles/storage.admin"
for ROLE_NAME in ${TF_SA_ROLES_LIST}
do
  LOG_DATE=`date`
  echo "${LOG_DATE} Adding role .. " ${ROLE_NAME}
  ${GCLOUD_BIN} projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${TERRAFORM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com --role ${ROLE_NAME}

  if [ ! $? -eq 0 ];then
      LOG_DATE=`date`
      echo "Unable to run ${GCLOUD_BIN} projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${TERRAFORM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com --role ${ROLE_NAME}"
      exit 1
  fi
done

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Sleeping 1m to propagate IAM changes ..."
sleep 60

if [ -f ${TERRAFORM_KEY_LOCATION} ]; then
    LOG_DATE=`date`
    echo "${LOG_DATE} ${TERRAFORM_KEY_LOCATION} exists."
    rm ${TERRAFORM_KEY_LOCATION}
fi
LOG_DATE=`date`
echo "Creating SA key ..."

${GCLOUD_BIN} iam service-accounts keys create ${TERRAFORM_KEY_LOCATION} --iam-account=${TERRAFORM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
if [ ! $? -eq 0 ];then
    LOG_DATE=`date`
    echo "Unable to run ${GCLOUD_BIN} iam service-accounts keys create ${TERRAFORM_KEY_LOCATION} --iam-account=${TERRAFORM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
    exit 1
fi
LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Launching Terraform core ..."

export TF_VAR_project_id=${PROJECT_ID}
export TF_VAR_region=${REGION}
export TF_VAR_terraform_key_location=${CONFIG_DIR}/${TERRAFORM_KEY_LOCATION}
export TF_VAR_dataproc_cluster_name=${DATAPROC_CLUSTER_NAME}
export TF_VAR_bucket_name=${BUCKET_NAME}
export TF_VAR_bq_dataset_name=${BQ_DATASET_NAME}

echo "TF var project_id : ${PROJECT_ID}"
echo "TF var region : ${REGION}"
echo "TF var terraform_key_location : ${CONFIG_DIR}/${TERRAFORM_KEY_LOCATION}"
echo "TF var dataproc_cluster_name : ${DATAPROC_CLUSTER_NAME}"
echo "TF var bucket_name : ${BUCKET_NAME}"
echo "TF var bq_dataset_name : ${BQ_DATASET_NAME}"


LOG_DATE=`date`
echo "${LOG_DATE} Deploying infra  ..."
TF_CORE_DIR=${CONFIG_DIR}/tf_core
TF_DATA_DIR=${CONFIG_DIR}/tf_data
cd ${TF_CORE_DIR}
export PLAN_NAME_CORE="spark-workshop-dbt-infra-core.plan"
${TERRAFORM_BIN} init -reconfigure
${TERRAFORM_BIN} plan -out=${PLAN_NAME_CORE}
${TERRAFORM_BIN} apply ${PLAN_NAME_CORE}

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Staging seed data in: ${BUCKET_NAME} ..."
CUSTOMER_RAW_DATA=${DATA_DIR}/cust_raw_data/*.parquet
SERVICE_DATA=${DATA_DIR}/service_threshold_data.csv
TELECOM_DATA=${DATA_DIR}/telecom_customer_churn_data.csv
TARGET=gs://${BUCKET_NAME}/data/

${GSUTIL_BIN} cp ${CUSTOMER_RAW_DATA} ${TARGET}
${GSUTIL_BIN} cp ${SERVICE_DATA} ${TARGET}
${GSUTIL_BIN} cp ${TELECOM_DATA} ${TARGET}
LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Launching Terraform data ..."
cd ${TF_DATA_DIR}
export TF_VAR_customer_data_gcs_uri=${TARGET}*.parquet
export TF_VAR_service_data_gcs_uri=${TARGET}service_threshold_data.csv
export TF_VAR_telecom_data_gcs_uri=${TARGET}telecom_customer_churn_data.csv
export PLAN_NAME_DATA="spark-workshop-dbt-infra-data.plan"
${TERRAFORM_BIN} init -reconfigure
${TERRAFORM_BIN} plan -out=${PLAN_NAME_DATA}
${TERRAFORM_BIN} apply ${PLAN_NAME_DATA}
mkdir -p ${SCRIPTS_DIR}/dbt_bq_spark/profiles
DBT_PROFILE_FILENAME=${SCRIPTS_DIR}/dbt_bq_spark/profiles/profiles.yml
echo "#################################################################"
echo "${LOG_DATE} Generating dbt profiles file: ${DBT_PROFILE_FILENAME} ..."

echo "dbt_bq_spark:" >  ${DBT_PROFILE_FILENAME}
echo "  outputs:" >>  ${DBT_PROFILE_FILENAME}
echo "    dev:" >>  ${DBT_PROFILE_FILENAME}
echo "      dataset: ${BQ_DATASET_NAME}" >>  ${DBT_PROFILE_FILENAME}
echo "      job_execution_timeout_seconds: 300" >>  ${DBT_PROFILE_FILENAME}
echo "      job_retries: 1" >>  ${DBT_PROFILE_FILENAME}
echo "      keyfile: ${CONFIG_DIR}/${TERRAFORM_KEY_LOCATION}" >>  ${DBT_PROFILE_FILENAME}
echo "      location: ${REGION}" >>  ${DBT_PROFILE_FILENAME}
echo "      method: service-account" >>  ${DBT_PROFILE_FILENAME}
echo "      priority: interactive" >>  ${DBT_PROFILE_FILENAME}
echo "      project: ${PROJECT_ID}" >>  ${DBT_PROFILE_FILENAME}
echo "      threads: 1" >>  ${DBT_PROFILE_FILENAME}
echo "      gcs_bucket: ${BUCKET_NAME}" >>  ${DBT_PROFILE_FILENAME}
echo "      dataproc_cluster_name: ${DATAPROC_CLUSTER_NAME}" >>  ${DBT_PROFILE_FILENAME}
echo "      dataproc_region:  ${REGION}" >>  ${DBT_PROFILE_FILENAME}
echo "      type: bigquery" >>  ${DBT_PROFILE_FILENAME}
echo "  target: dev" >>  ${DBT_PROFILE_FILENAME}

DBT_MODEL_FILENAME=${SCRIPTS_DIR}/dbt_bq_spark/models/dbt_bq_spark.yml
echo "#################################################################"
echo "${LOG_DATE} Generating dbt models config file: ${DBT_MODEL_FILENAME} ..."
echo "version: 2" >  ${DBT_MODEL_FILENAME}
echo "sources:" >>  ${DBT_MODEL_FILENAME}
echo "  - name: ${BQ_DATASET_NAME}" >>  ${DBT_MODEL_FILENAME}
echo "    tables:" >>  ${DBT_MODEL_FILENAME}
echo "      - name: cust_raw_data" >>  ${DBT_MODEL_FILENAME}
echo "      - name: service_data" >>  ${DBT_MODEL_FILENAME}
echo "      - name: telecom_data" >>  ${DBT_MODEL_FILENAME}

LOG_DATE=`date`
echo "#################################################################"
echo "${LOG_DATE} Execution finished! ..."

