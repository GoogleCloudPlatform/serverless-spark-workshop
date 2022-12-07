#  Copyright 2022 Google LLC
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

#!/bin/bash

#........................................................................
# Purpose: Copy existing notebooks to Workbench server Jupyter home dir
# (Managed notebook server)
#........................................................................

gsutil cp gs://USER_ID-s8s_notebook_bucket-PROJECT_NBR/pyspark/*.ipynb /home/jupyter/
#sudo chown jupyter:jupyter /home/jupyter/*
