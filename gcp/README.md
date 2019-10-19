# gcp

This config manages the resources in other GCP projects running in Google Cloud.

It depends on the use of the `charlieegan3-config` GCP project - this
must be manually created and configured as follows:

```
service_account_name=terraform-admin
project=charlieegan3-config

gcloud projects create $project
gcloud services enable cloudresourcemanager.googleapis.com

# connect a billing account
billing_account_id=$(gcloud beta billing accounts list | grep Monzo | awk '{ print $1 }')
gcloud beta billing projects link $project --billing-account=$billing_account_id

# Next create a bucket for the terraform state
gsutil mb -p $project gs://$project-tf-state

# This saves the default creds
gcloud auth application-default login
# => /home/charlieegan3/.config/gcloud/application_default_credentials.json

# You may wish to move this file and save it as a separate file, it can then be referenced in an `.envrc`
export GOOGLE_APPLICATION_CREDENTIALS=/home/charlieegan3/.config/gcloud/default_creds.json
```

Now ensure that the project name is the same in the terraform `main.tf` file and
run `terraform init`.

## Example `.envrc`

```
export GOOGLE_PROJECT=charlieegan3-config
export CLOUDSDK_ACTIVE_CONFIG_NAME=default
export GOOGLE_APPLICATION_CREDENTIALS=/home/charlieegan3/.config/gcloud/default_creds.json
export GOOGLE_REGION=us-east1
```
