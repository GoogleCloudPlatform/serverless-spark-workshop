'''
  Copyright 2022 Google LLC
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
'''

import json
from google.cloud import aiplatform as vertex_ai
import functions_framework
import os, random
from os import path
from google.cloud import storage
from urllib.parse import urlparse, urljoin


def process_request(request):
   """Processes the incoming HTTP request.
   Args:
     request (flask.Request): HTTP request object.
   Returns:
     The response text or any set of values that can be turned into a Response
     object using `make_response
     <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
   """

   # decode http request payload and translate into JSON object
   request_str = request.data.decode('utf-8')
   request_json = json.loads(request_str)

   # ........................................
   # Capture and print environment variables
   # ........................................

   # a) Pipeline template file in GCS
   VAI_PIPELINE_JSON_TEMPLATE_GCS_FILE_FQN = os.environ.get("VAI_PIPELINE_JSON_TEMPLATE_GCS_FILE_FQN")
   print("VAI_PIPELINE_JSON_TEMPLATE_GCS_FILE_FQN is {}".format(VAI_PIPELINE_JSON_TEMPLATE_GCS_FILE_FQN))

   # b) Pipeline execution directory in GCS
   VAI_PIPELINE_JSON_EXEC_DIR_URI = os.environ.get("VAI_PIPELINE_JSON_EXEC_DIR_URI")
   print("VAI_PIPELINE_JSON_EXEC_DIR_URI is {}".format(VAI_PIPELINE_JSON_EXEC_DIR_URI))

   # c) Project ID
   PROJECT_ID = os.environ.get("PROJECT_ID")
   print("PROJECT_ID is {}".format(PROJECT_ID))

   # d) GCP location
   GCP_LOCATION = os.environ.get("GCP_LOCATION")
   print("GCP_LOCATION is {}".format(GCP_LOCATION))

   # e) VAI pipeline root for logs
   VAI_PIPELINE_ROOT_LOG_DIR = os.environ.get("VAI_PIPELINE_ROOT_LOG_DIR")
   print("VAI_PIPELINE_ROOT_LOG_DIR is {}".format(VAI_PIPELINE_ROOT_LOG_DIR))

   # ........................................
   # Create local scratch directory in /tmp
   # ........................................

   LOCAL_SCRATCH_DIR = "/tmp/scratch"
   if not os.path.exists(LOCAL_SCRATCH_DIR):
    os.makedirs(LOCAL_SCRATCH_DIR)

   # ........................................
   # Variables
   # ........................................

   # a) Generate custom job ID for Vertex AI pipeline run
   vaiPipelineExecutionInstanceID = random.randint(1, 10000)
   print("VAI_PIPELINE_EXECUTION_INSTANCE_ID is {}".format(vaiPipelineExecutionInstanceID))

   # b) Customized pipeline JSON filename
   pipelineFileName = "pipeline_{}.json".format(vaiPipelineExecutionInstanceID)
   print("PIPELINE_FILE_NM is {}".format(pipelineFileName))

   # c) Local path to customized pipeline JSON
   localCustomPipelineJsonFileFQN = LOCAL_SCRATCH_DIR + "/" + pipelineFileName
   print("VAI_PIPELINE_JSON_TO_EXECUTE is locally at {}".format(localCustomPipelineJsonFileFQN))

   # d) Local (download) path for template pipeline JSON
   localTemplatePipelineJsonFileFQN = LOCAL_SCRATCH_DIR + "/customer_churn_template.json"

   # e) GCS URI for customized pipeline JSON
   PIPELINE_JSON_GCS_URI = VAI_PIPELINE_JSON_EXEC_DIR_URI + "/executions/{}".format(pipelineFileName)

   # ........................................
   # Create custom VAI pipeline JSON
   # ........................................

   # a) Download the template VAI pipeline JSON
   downloadVaiPipelineTemplateInGCS(VAI_PIPELINE_JSON_TEMPLATE_GCS_FILE_FQN,localTemplatePipelineJsonFileFQN)

   # b) Create custom VAI pipeline JSON
   createCustomVaiPipelineJson(vaiPipelineExecutionInstanceID,localTemplatePipelineJsonFileFQN,localCustomPipelineJsonFileFQN)

   # c) Push custom VAI pipeline JSON to GCS execution directory
   pushLocalFileToGCS(urlparse(VAI_PIPELINE_JSON_EXEC_DIR_URI).netloc, localCustomPipelineJsonFileFQN, "executions/{}".format(pipelineFileName))

   # ........................................
   # Vertex AI Pipeline execution
   # ........................................

   vertex_ai.init(
       project=PROJECT_ID,
       location=GCP_LOCATION,
       staging_bucket=VAI_PIPELINE_ROOT_LOG_DIR
   )

   job = vertex_ai.PipelineJob(
       display_name='customer-churn-prediction-pipeline',
       template_path=PIPELINE_JSON_GCS_URI,
       pipeline_root=VAI_PIPELINE_ROOT_LOG_DIR,
       enable_caching=False
   )

   job.submit()
   return "Job submitted"

#}} End of entry point

def downloadVaiPipelineTemplateInGCS(gcsFQVaiPipelineTemplateJsonFileUri, fileToDownloadToLocally):
#{{
   googleCloudStorageClient = storage.Client()
   with open(fileToDownloadToLocally, 'wb') as fileObject:
    googleCloudStorageClient.download_blob_to_file(
        gcsFQVaiPipelineTemplateJsonFileUri, fileObject)

   print("Downloaded template to {}".format(fileToDownloadToLocally))
#}}

def createCustomVaiPipelineJson(pipelineID, templatePipelineJsonLocalFile, customPipelineJsonLocalFile):
#{{
    searchText = "YOUR_USER_DEFINED_EXECUTION_ID"
    replaceText = str(pipelineID)

    with open(templatePipelineJsonLocalFile, 'r') as templateFileHandle:
        templateContent = templateFileHandle.read()
        customContent = templateContent.replace(searchText, replaceText)

    with open(customPipelineJsonLocalFile, 'w') as customFileHandle:
        customFileHandle.write(customContent)

    print("Created customPipelineJsonLocalFile at {}".format(customPipelineJsonLocalFile))
#}}

def pushLocalFileToGCS(executionPipelineGCSDirUri, customPipelineJsonLocalFilePath, customPipelineFileName):
#{{
    googleCloudStorageClient = storage.Client()
    googleCloudStorageBucket = googleCloudStorageClient.bucket(executionPipelineGCSDirUri)
    blob = googleCloudStorageBucket.blob(customPipelineFileName)
    blob.upload_from_filename(customPipelineJsonLocalFilePath)
#}}
