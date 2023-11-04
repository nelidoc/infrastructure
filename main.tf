data "google_project" "project" {}

provider "google" {
  project     = "nelidoc"
  region      = "europe-west1"
}

terraform {
  backend "gcs" {
    bucket  = "nelidoc-tfstates"
    prefix  = "terraform/state"
  }
}



resource "google_storage_bucket" "tfstate" {
  name          = "nelidoc-tfstates"
  location      = "europe-west1"
  
  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }
}