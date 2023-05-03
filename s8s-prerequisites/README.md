# GCP Project Setup Prerequisites for Serverless Spark Labs

## 1. About

This repo is a guide to walk a GCP project Admin step-by-step through the process of setting up and validating the GCP resources required to conduct the hands-on Serverless Spark labs using Terraform.

## 2. GCP Resources Used

- Google Cloud APIs
- VPC Network, Subnet, Firewall Rule and VPC Network Peering
- User Managed Service Accounts
- Persistent History Server (Dataproc on GCE Single Node cluster)
- BigQuery Dataset
- Dataproc Metastore Service
- Composer Environment
- Google Cloud Storage Buckets

## 3. Permissions / IAM Roles required to setup the prerequisites

Following permissions / roles are required to execute the prerequisites

- Security Admin
- Project IAM Admin
- Service Usage Admin
- Service Account Admin
- Role Administrator

## 4. Modules

Please execute the following modules in sequence:

- [Resource Creation](01-instructions/01-terraform-instructions.md)
- [Setup Validation](01-instructions/02-setup-validation.md)

## 5. Dont forget to
Shut down/delete resources when done to avoid unnecessary billing.
