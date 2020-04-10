provider "google" {
  version = "2.20.0"
}

provider "google-beta" {
  version = "2.20.0"
}

terraform {
  required_version = "0.12.11"

  backend "remote" {
    organization = "charlieegan3"

    workspaces {
      name = "my-app-prod"
    }
  }
}

variable "billing_account" {
  default = "005E2D-B6C22B-0274AA"
}
