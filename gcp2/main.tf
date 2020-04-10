provider "google" {}
provider "google-beta" {}

terraform {
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
