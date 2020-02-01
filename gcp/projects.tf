module "charlieegan3-music" {
  source          = "./charlieegan3-music"
  org_id          = var.org_id
  billing_account = var.billing_account
}

module "charlieegan3-cluster" {
  source          = "./charlieegan3-cluster"
  org_id          = var.org_id
  billing_account = var.billing_account
}

module "charlieegan3-billing-export" {
  source          = "./charlieegan3-billing-export"
  org_id          = var.org_id
  billing_account = var.billing_account
}

module "charlieegan3-stackr" {
  source          = "./charlieegan3-stackr"
  org_id          = var.org_id
  billing_account = var.billing_account
}

module "charlieegan3-instagram-archive" {
  source          = "./charlieegan3-instagram-archive"
  org_id          = var.org_id
  billing_account = var.billing_account
}

module "charlieegan3-inlets" {
  source          = "./charlieegan3-inlets"
  org_id          = var.org_id
  billing_account = var.billing_account
}
