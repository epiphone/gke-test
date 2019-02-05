# gke-test
[![CircleCI](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master.svg?style=svg)](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master)

Exploring Google Kubernetes Engine. Includes
- a simple dockerized test app
- A [private](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters) GKE cluster with [container-native load-balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing) and a single node pool
- infrastructure defined with Terraform
- multiple environments
- CI pipeline on CircleCI
  - run `app/` tests and validate `k8s/` declarations with [`kubeval`](https://github.com/garethr/kubeval/)
  - push to any non-master branch triggers update to `dev` environment
  - push to `master` branch triggers update to `test` environment
  - additional approval step at CircleCI UI after `test` environment update triggers `production` environment update
  - Terraform plan file and newly built Docker image tag are stored into CircleCI artifacts

## Dependencies
- [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [gcloud](https://cloud.google.com/sdk/#Quick_Start) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for local testing

## Setup

The following steps need to be completed manually to set up the project before automation kicks in:

1. Create a new Google Cloud project per each environment
2. For each Google Cloud project,
    - set up a Cloud Storage bucket for [remote Terraform state](https://www.terraform.io/docs/backends/types/gcs.html)
    - set up a service IAM account to be used by Terraform. Attach the `Editor` role to the created user
    - run `cd terraform/<ENV> && terraform init` to initialize Terraform providers
3. Add environment variables to your CircleCI config
  - `GOOGLE_PROJECT_ID_DEV`, `GOOGLE_PROJECT_ID_TEST` and `GOOGLE_PROJECT_ID_PROD`: Environment-specific Google project id
  - `GCLOUD_SERVICE_KEY_DEV`, `GCLOUD_SERVICE_KEY_TEST` and `GCLOUD_SERVICE_KEY_PROD`: Environment-specific service account key
  - `K8S_MASTER_ALLOWED_IP`: IP from which to access the cluster master's public endpoint, [read more](https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks)

## Manual deployment

You can also sidestep CI and deploy locally:

1. [Login](https://www.terraform.io/docs/providers/google/provider_reference.html) to Google Cloud: `gcloud auth application-default login`
1. Update infra: `cd terraform/dev && terraform init && terraform apply`
2. Follow [instructions](https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app) on building and pushing a Docker image to GKE:
    - `cd app`
    - `export PROJECT_ID="$(gcloud config get-value project -q)"`
    - `docker build -t gcr.io/${PROJECT_ID}/gke-app:v1 .`
    - `gcloud docker -- push gcr.io/${PROJECT_ID}/gke-app:v1`
3. Authenticate `kubectl`: `gcloud container clusters get-credentials $(terraform output cluster_name) --zone=$(terraform output cluster_zone)`
4. Set Kubernetes variables: `PROJECT_NAME=gke-dev APP_IMAGE=eu.gcr.io/... envsubst < k8s/k8s.yml > k8s_filled.yml`
5. Update Kubernetes resources: `kubectl apply -f k8s_filled.yml`

## TODO

- Postgres instance on Cloud SQL
- prevent Cloud SQL destroy akin to Cloudformation `retain`: https://www.terraform.io/docs/configuration/resources.html#meta-parameters
- private cluster
- HTTPS
- secrets
- tune down Terraform IAM user role, least privilege
- [regional GKE cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters)
- set Google Cloud provider services https://cloud.google.com/service-usage/docs/list-services
- clean up old container images from GCR
- reduce duplication in CircleCI config
- prompt for extra approval on infra changes in master
- [static assets to Cloud Storage & CDN](https://cloud.google.com/load-balancing/docs/https/adding-a-backend-bucket-to-content-based-load-balancing#using_cloud_cdn_with_cloud_storage_buckets)
- don't rebuild docker image from `test` to `prod`?
- smoke tests [in CI](https://github.com/eddiewebb/circleci-multi-cloud-k8s/blob/master/.circleci/config.yml)
- structured logging to Stackdriver
