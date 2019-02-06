# gke-test
[![CircleCI](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master.svg?style=svg)](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master)

Exploring Google Kubernetes Engine. Includes
- A [**private** GKE cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters) with [container-native load-balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing) and a single node pool
- Postgres Cloud SQL instance with [private networking](https://cloud.google.com/blog/products/databases/introducing-private-networking-connection-for-cloud-sql)
- infrastructure defined with **Terraform**
- **multi-env** CI pipeline on **CircleCI**
  - push to any non-master branch triggers update to `dev` environment
  - push to `master` branch triggers update to `test` environment
  - additional approval step at CircleCI UI after `test` environment update triggers `prod` environment update
  - Terraform plan file, Kubernetes config and newly built Docker image tag are stored into CircleCI artifacts

## Setup

The following steps need to be completed manually before automation kicks in:

1. Create a new Google Cloud project per each environment
2. For each Google Cloud project,
    - set up a Cloud Storage bucket for storing [remote Terraform state](https://www.terraform.io/docs/backends/types/gcs.html)
    - set up a service IAM account to be used by Terraform. Attach the `Editor` and `Compute Network Agent` roles to the created user
    - run `cd terraform/<ENV> && terraform init` to initialize Terraform providers
3. Set environment variables in your CircleCI project:
    - `GOOGLE_PROJECT_ID_DEV`, `GOOGLE_PROJECT_ID_TEST` and `GOOGLE_PROJECT_ID_PROD`: environment-specific Google project id
    - `GCLOUD_SERVICE_KEY_DEV`, `GCLOUD_SERVICE_KEY_TEST` and `GCLOUD_SERVICE_KEY_PROD`: environment-specific service account key
    - `K8S_MASTER_ALLOWED_IP`: IP from which to access cluster master's public endpoint, i.e. the IP where you run `kubectl` at ([read more](https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks))
      - In CircleCI we temporarily add the test host's IP to cluster master's whitelist in order to run `kubectl`

## Manual deployment

You can also sidestep CI and deploy locally:

1. Install [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html), [gcloud](https://cloud.google.com/sdk/#Quick_Start) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. [Login](https://www.terraform.io/docs/providers/google/provider_reference.html) to Google Cloud: `gcloud auth application-default login`
3. Update infra: `cd terraform/dev && terraform init && terraform apply`
4. Follow [instructions](https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app) on building and pushing a Docker image to GKE:
    - `cd app`
    - `export PROJECT_ID="$(gcloud config get-value project -q)"`
    - `docker build -t gcr.io/${PROJECT_ID}/gke-app:v1 .`
    - `gcloud docker -- push gcr.io/${PROJECT_ID}/gke-app:v1`
5. Authenticate `kubectl`: `gcloud container clusters get-credentials $(terraform output cluster_name) --zone=$(terraform output cluster_zone)`
6. Set Kubernetes variables: `PROJECT_NAME=gke-dev APP_IMAGE=eu.gcr.io/... envsubst < k8s/k8s.yml > k8s_filled.yml`
7. Update Kubernetes resources: `kubectl apply -f k8s_filled.yml`

Read [here](https://cloud.google.com/sql/docs/postgres/quickstart-proxy-test) on how to connect to the Cloud SQL instance with a local `psql` client.

## TODO

- Cloud SQL disable public IP: Terraform's `ip_configuration.ipv4_enabled = false` setting seems to bear no effect
- Cloud SQL high availability
- HTTPS
- tune down Terraform IAM user role, least privilege
- [regional GKE cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters)
- clean up old container images from GCR
- reduce duplication in CircleCI config
- prompt for extra approval on infra changes in master
- [static assets to Cloud Storage & CDN](https://cloud.google.com/load-balancing/docs/https/adding-a-backend-bucket-to-content-based-load-balancing#using_cloud_cdn_with_cloud_storage_buckets)
- don't rebuild docker image from `test` to `prod`?
- smoke tests [in CI](https://github.com/eddiewebb/circleci-multi-cloud-k8s/blob/master/.circleci/config.yml)
- structured logging to Stackdriver
