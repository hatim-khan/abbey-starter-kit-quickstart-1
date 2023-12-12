terraform {
  backend "http" {
    address        = "https://api.abbey.io/terraform-http-backend"
    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.6"
    }
  }
}

locals {
  username = "" #CHANGEME
  repo_name = "" #CHANGEME

  repo = "github://${local.username}/${local.repo_name}"
  location = "${local.repo}/access.tf"
  policies = "${local.repo}/policies"

  reviewers = [
    "alice@example.com", #CHANGEME
  ]
}

provider "abbey" {
  # Configuration options
  bearer_auth = var.abbey_token
}

resource "abbey_grant_kit" "abbey_demo_site" {
  name = "Abbey_Demo_Site"
  description = <<-EOT
    Grants access to Abbey's Demo Page.
  EOT

  workflow = {
    steps = [
      {
        reviewers = {
          one_of = local.reviewers
        }
      }
    ]
  }

  policies = [
    { bundle = local.policies } # CHANGEME
  ]

  output = {
    location = local.ouput_location
    append = <<-EOT
      resource "abbey_demo" "grant_read_write_access" {
        permission = "read_write"
        email = "{{ .data.system.abbey.identities.abbey.email }}"
      }
    EOT
  }
}
