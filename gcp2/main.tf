provider "google" {}
provider "google-beta" {}

terraform {
  backend "remote" {
    organization = "charlieegan3"

    workspaces {
      name = "infrastructure"
    }
  }
}

variable "billing_account" {
  default = "010433-8679E7-929391"
}
