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

PIP_BIN=`which pip3`
TERRAFORM_BIN=`which terraform`
GCLOUD_BIN=`which gcloud`
JQ_BIN=`which jq`
GIT_BIN=`which git`

LOG_DATE=`date`
echo "###########################################################################################"
echo "${LOG_DATE} cell-tower-anomaly-detection-dbt lab infrastructure deployment - Starting  .."

if [ "${#}" -ne 2 ]; then
    echo "Illegal number of parameters. Exiting ..."
    echo "Usage: ${0} <VARIABLES_FILE> <(DEPLOY|DESTROY)>"
    echo "Example: ${0} variables.json deploy"
    exit 1
fi

if [ ! "${CLOUD_SHELL}" = true ] ; then
    echo "This script needs to run on Google Cloud Shell. Exiting ..."
    exit 1
fi

CONFIG_FILE="${1}"
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Unable to find ${CONFIG_FILE}"
    exit 1
fi

COMMAND="${2}"
if [[ ! "${COMMAND}" =~ ^(deploy|destroy)$ ]]; then
    echo "Command needs to be deploy | destroy. Exiting ..."
    exit 1
fi

LOG_DATE=`date`
echo "###########################################################################################"
echo "${LOG_DATE} Reading and parsing config file  ${CONFIG_FILE}.."

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

export DBT_SA_NAME=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.dbt_sa_name'`
if [ -z "${DBT_SA_NAME}" ]
then
      echo "Error reading DBT_SA_NAME"
      exit 1
else
    echo "DBT_SA_NAME : ${DBT_SA_NAME}"
fi

export DBT_SA_KEY_LOCATION=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.dbt_sa_key_location'`
if [ -z "${DBT_SA_KEY_LOCATION}" ]
then
      echo "Error reading DBT_SA_KEY_LOCATION"
      exit 1
else
    echo "DBT_SA_KEY_LOCATION : ${CONFIG_DIR}/${DBT_SA_KEY_LOCATION}"
fi

export SPARK_SERVERLESS=`cat "${CONFIG_FILE}" | "${JQ_BIN}" -r '.spark_serverless'`
if [ -z "${SPARK_SERVERLESS}" ]
then
      echo "Error reading SPARK_SERVERLESS"
      exit 1
else
    echo "SPARK_SERVERLESS :  ${SPARK_SERVERLESS}"
fi


"${GCLOUD_BIN}" config set project ${PROJECT_ID}
if [ ! "${?}" -eq 0 ];then
    LOG_DATE=`date`
    echo "Unable to run ${GCLOUD_BIN} config set project ${PROJECT_ID}"
    exit 1
fi


BASE_DIR="${PWD}"/..
SCRIPTS_DIR="${BASE_DIR}"/00-scripts
DATA_DIR="${BASE_DIR}"/01-datasets
CONFIG_DIR="${BASE_DIR}"/02-config
TF_CORE_DIR="${CONFIG_DIR}"/terraform

PROJECT_APIS_LIST='["compute.googleapis.com" , "dataproc.googleapis.com" , "bigquery.googleapis.com" , "storage.googleapis.com" , "iam.googleapis.com" , "iamcredentials.googleapis.com" ,"orgpolicy.googleapis.com"]'
DBT_SA_ROLES_LIST='["roles/bigquery.admin","roles/dataproc.admin","roles/iam.serviceAccountUser","roles/storage.admin"]'



CUSTOMER_DATA_FILES="customers_raw_data/*.parquet"
SERVICE_DATA_FILES="service_raw_data/service_threshold_data.csv"
TELECOM_DATA_FILES="telecom_raw_data/telecom_customer_churn_data.csv"


SRC_CUSTOMER_DATA="${DATA_DIR}"/"${CUSTOMER_DATA_FILES}"
SRC_SERVICE_DATA="${DATA_DIR}"/"${SERVICE_DATA_FILES}"
SRC_TELECOM_DATA="${DATA_DIR}"/"${TELECOM_DATA_FILES}"


DST_CUSTOMER_DATA=gs://"${BUCKET_NAME}"/data/customers_raw_data
DST_SERVICE_DATA=gs://"${BUCKET_NAME}"/data/service_raw_data
DST_TELECOM_DATA=gs://"${BUCKET_NAME}"/data/telecom_raw_data


PLAN_NAME_CORE="spark-workshop-dbt-infra-core.plan"


# Workaround https://github.com/hashicorp/terraform-provider-google/issues/6782
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 net.ipv6.conf.default.disable_ipv6=1 net.ipv6.conf.lo.disable_ipv6=1 > /dev/null
export BUG_APIS="googleapis.com www.googleapis.com storage.googleapis.com iam.googleapis.com container.googleapis.com cloudresourcemanager.googleapis.com"
for NAME in ${BUG_APIS}
do
  ipv4=$(getent ahostsv4 "${NAME}" | head -n 1 | awk '{ print $1 }')
  grep -q "${NAME}" /etc/hosts || ([ -n "$ipv4" ] && sudo sh -c "echo '$ipv4 ${NAME}' >> /etc/hosts")
done
# Workaround end


LOG_DATE=`date`
echo "###########################################################################################"
echo "${LOG_DATE} Launching Terraform ..."


export TF_VAR_project_id="${PROJECT_ID}"
export TF_VAR_region="${REGION}"
export TF_VAR_project_apis_list="${PROJECT_APIS_LIST}"
export TF_VAR_dbt_sa_name="${DBT_SA_NAME}"
export TF_VAR_dbt_sa_key_location="${CONFIG_DIR}"/"${DBT_SA_KEY_LOCATION}"
export TF_VAR_dbt_sa_roles_list="${DBT_SA_ROLES_LIST}"
export TF_VAR_dataproc_cluster_name="${DATAPROC_CLUSTER_NAME}"
export TF_VAR_bucket_name="${BUCKET_NAME}"
export TF_VAR_bq_dataset_name="${BQ_DATASET_NAME}"
export TF_VAR_spark_serverless="${SPARK_SERVERLESS}"


export TF_VAR_src_customer_data="${SRC_CUSTOMER_DATA}"
export TF_VAR_src_service_data="${SRC_SERVICE_DATA}"
export TF_VAR_src_telecom_data="${SRC_TELECOM_DATA}"

export TF_VAR_dst_customer_data="${DST_CUSTOMER_DATA}"
export TF_VAR_dst_service_data="${DST_SERVICE_DATA}"
export TF_VAR_dst_telecom_data="${DST_TELECOM_DATA}"


LOG_DATE=`date`
echo "###########################################################################################"
echo "${LOG_DATE} - TF Variables:"
echo "TF var project_id : ${PROJECT_ID}"
echo "TF var region : ${REGION}"
echo "TF var project_api_list : ${PROJECT_APIS_LIST}"
echo "TF var dbt_sa_name : ${DBT_SA_NAME}"
echo "TF var dbt_sa_key_location : ${CONFIG_DIR}/${DBT_SA_KEY_LOCATION}"
echo "TF var dbt_sa_roles_list : ${DBT_SA_ROLES_LIST}"
echo "TF var dataproc_cluster_name : ${DATAPROC_CLUSTER_NAME}"
echo "TF var bucket_name : ${BUCKET_NAME}"
echo "TF var bq_dataset_name : ${BQ_DATASET_NAME}"
echo "TF var spark_serverless : ${SPARK_SERVERLESS}"
echo "TF var src_customer_data : ${SRC_CUSTOMER_DATA}"
echo "TF var src_service_data  : ${SRC_SERVICE_DATA}"
echo "TF var src_telecom_data  : ${SRC_TELECOM_DATA}"
echo "TF var  dst_customer_data : ${DST_CUSTOMER_DATA}"
echo "TF var  dst_service_data : ${DST_SERVICE_DATA}"
echo "TF var  dst_telecom_data : ${DST_TELECOM_DATA}"


cd "${TF_CORE_DIR}" || exit 1
"${TERRAFORM_BIN}" init -reconfigure
"${TERRAFORM_BIN}" plan -out="${PLAN_NAME_CORE}"

if [ "${COMMAND}" = "deploy" ] ; then
    "${TERRAFORM_BIN}" apply "${PLAN_NAME_CORE}"
    if [ ! "${?}" -eq 0 ]; then
        LOG_DATE=`date`
        echo "${LOG_DATE} Unable to run ${TERRAFORM_BIN} apply ${PLAN_NAME_CORE}"
        exit 1
    fi
    LOG_DATE=`date`
    echo "###########################################################################################"
    echo "${LOG_DATE} Installing dbt-bigquery on Cloud Shell  .."
    BETA_RELEASE_PYPIP="1.3.0b1"
    "${PIP_BIN}" install dbt-bigquery=="${BETA_RELEASE_PYPIP}"
    #As per [CT-255] [Bug] ImportError: cannot import name soft_unicode from markupsafe (https://github.com/dbt-labs/dbt-core/issues/4745)
    "${PIP_BIN}" install --force-reinstall MarkupSafe==2.0.1
    LOG_DATE=`date`
    echo "###########################################################################################"
    echo "${LOG_DATE} dbt deployed OK"

    LOG_DATE=`date`
    echo "###########################################################################################"
    echo "${LOG_DATE} Installing extra packages needed for dbt.."

    PIP_PACKAGES="google-cloud-dataproc google-cloud-storage"
    for PIP_PACKAGE in ${PIP_PACKAGES}
    do
    LOG_DATE=`date`
    echo "${LOG_DATE} Deploying PIP package ..  ${PIP_PACKAGE}"
    "${PIP_BIN}" install ${PIP_PACKAGE}
    if [ ! "${?}" -eq 0 ];then
        LOG_DATE=`date`
        echo "Unable to run  ${PIP_BIN} install ${PIP_PACKAGE}"
        exit 1
    fi
    done
    if [ "${SPARK_SERVERLESS}" = true ] ; then
        echo "Enabling experimental support for spark serverless .."
        echo "WARNING: This is a experimental release!"
        #Clone repo with experimental suport
        DBT_GIT_REPO="https://github.com/dbt-labs/dbt-bigquery.git"
        SERVERLESS_SPARK_EXPERIMENTAL_DEV_BRANCH="jerco/dataproc-serverless-experiment"
        "${GIT_BIN}" clone --branch  "${SERVERLESS_SPARK_EXPERIMENTAL_DEV_BRANCH}"  "${DBT_GIT_REPO}"
        #Force uninstall previous version of dbt
        "${PIP_BIN}" uninstall dbt-core -y
        "${PIP_BIN}" uninstall dbt-bigquery -y
        #Builds bdt from source
        DBT_PATH="${PWD}"/dbt-bigquery
        "${DBT_PATH}"/scripts/build-dist.sh
        #Installs the dist
        "${PIP_BIN}" install "${DBT_PATH}"/dist/*.whl
    fi
    mkdir -p "${SCRIPTS_DIR}"/dbt_bq_spark/profiles
    DBT_PROFILE_FILENAME="${SCRIPTS_DIR}"/dbt_bq_spark/profiles/profiles.yml
    echo "###########################################################################################"
    echo "${LOG_DATE} Generating dbt profiles file: ${DBT_PROFILE_FILENAME} ..."
    cat << EOF > "${DBT_PROFILE_FILENAME}"
dbt_bq_spark:
    outputs:
        dev:
          dataset: ${BQ_DATASET_NAME}
          job_execution_timeout_seconds: 300
          job_retries: 1
          keyfile: ${CONFIG_DIR}/${DBT_SA_KEY_LOCATION}
          location: ${REGION}
          method: service-account
          priority: interactive
          project: ${PROJECT_ID}
          threads: 1
          gcs_bucket: ${BUCKET_NAME}
          dataproc_cluster_name: ${DATAPROC_CLUSTER_NAME}
          dataproc_region:  ${REGION}
          type: bigquery
    target: dev
EOF
    DBT_MODEL_FILENAME=${SCRIPTS_DIR}/dbt_bq_spark/models/dbt_bq_spark.yml
    echo "###########################################################################################"
    echo "${LOG_DATE} Generating dbt models config file: ${DBT_MODEL_FILENAME} ..."
    cat << EOF > "${DBT_MODEL_FILENAME}"
version: 2
sources:
  - name: ${BQ_DATASET_NAME}
    tables:
    - name: customer_data
    - name: service_data
    - name: telecom_data
EOF
    else
        #destroy
        "${TERRAFORM_BIN}" "${COMMAND}"  -auto-approve
        if [ ! "${?}" -eq 0 ]; then
            LOG_DATE=`date`
            echo "${LOG_DATE} Unable to run ${TERRAFORM_BIN} ${COMMAND}  -auto-approve"
            exit 1
        fi
fi
LOG_DATE=`date`
echo "###########################################################################################"
echo "${LOG_DATE} Execution finished! ..."