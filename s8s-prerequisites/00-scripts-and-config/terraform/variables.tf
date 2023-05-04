/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


variable "project_id" {
  type        = string
  description = "project id required"
}
variable "project_number" {
 type        = string
 description = "project number in which demo deploy"
}
variable "gcp_account_name" {
 type        = string
 description = "user performing the demo"
}
variable "cloud_composer_image_version" {
 type        = string
 description = "Version of Cloud Composer 2 image to use"
}
variable "spark_container_image_tag" {
 type        = string
 description = "Tag number to assign to container image"
}
variable "gcp_region" {
 type        = string
 description = "GCP region"
}
variable "custom_container" {
 type        = string
 description = "Flag variable"
}
variable "create_composer" {
 type        = string
 description = "Flag variable"
}
variable "create_metastore" {
 type        = string
 description = "Flag variable"
}
