# gke-test
[![CircleCI](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master.svg?style=svg)](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master)

Exploring Google Kubernetes Engine. Includes
- a simple test app dockerized and running on Google Kubernetes Engine
- Postgres instance on Cloud SQL
- infrastructure defined with Terraform
- multiple environments
- CI pipeline on CircleCI
  - push to any non-master branch triggers update to `dev` environment
  - push to `master` branch triggers update to `test` environment
  - additional approval step at CircleCI UI after `test` environment update triggers `production` environment update

## Dependencies
- [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [gcloud](https://cloud.google.com/sdk/#Quick_Start) for local testing

## Setup

The following steps need to be completed manually to set up the project before automation kicks in:

1. Create a new Google Cloud project per each environment
2. For each Google Cloud project,
    - set up a Cloud Storage bucket for [remote Terraform state](https://www.terraform.io/docs/backends/types/gcs.html)
    - set up a service IAM account to be used by Terraform. Attach the `Editor` role to the created user
    - run `cd terraform/<ENV> && terraform init` to initialize Terraform providers
3. Add environment variables to your CircleCI config
  - `GCLOUD_SERVICE_KEY_DEV` and `GOOGLE_PROJECT_ID_DEV` plus the same for `_TEST` and `_PROD`

## Manual deployment

In cases where you need to sidestep CI and deploy something locally:

1. [Login](https://www.terraform.io/docs/providers/google/provider_reference.html) to Google Cloud: `gcloud auth application-default login`
1. Update infra: `cd terraform/dev && terraform apply`
2. Follow [instructions](https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app) on building and pushing a Docker image to GKE:
    - `cd app`
    - `export PROJECT_ID="$(gcloud config get-value project -q)"`
    - `docker build -t gcr.io/${PROJECT_ID}/hello-app:v1 .`
    - `gcloud docker -- push gcr.io/${PROJECT_ID}/hello-app:v1`

## TODO

- networking
- [load balancing](https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer)
- secrets
- tune down Terraform IAM user role, least privilege
- multizone GKE cluster
- explicitly define provider versions
- set Google Cloud provider services https://cloud.google.com/service-usage/docs/list-services
- prevent Cloud SQL destroy akin to Cloudformation `retain`: https://www.terraform.io/docs/configuration/resources.html#meta-parameters
- clean up old container images from GCR
- reduce duplication in CircleCI config
- prompt for extra approval on infra changes in master
