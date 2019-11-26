provider "google" {
  project = "charlieegan3-config"
  region  = "europe-west2-a"
  version = "2.20.0"
}

provider "google-beta" {
  project = "charlieegan3-config"
  region  = "europe-west2-a"
  version = "2.20.0"
}

terraform {
  required_version = "0.12.11"

  backend "gcs" {
    bucket = "charlieegan3-config-tf-state"
    prefix = "terraform/state"
  }
}

variable "billing_account" {
  default = "005E2D-B6C22B-0274AA"
}

variable "org_id" {
  default = "944445815146"
}

output "charlieegan3-cluster-vault-kms-key-id" {
  value = "${module.charlieegan3-cluster.vault_kms_key_id}"
}
