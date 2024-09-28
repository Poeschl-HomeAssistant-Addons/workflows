terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.3.0"
    }
  }
  # The terraform state is stored in the Terraform Cloud
  cloud {
    organization = "Home-Assistant-Addons"
    workspaces {
      name = "Addon-Repository-IaC"
    }
  }
}

provider "github" {
  // Make sure the "GITHUB_TOKEN" env is set
  owner = "Poeschl-HomeAssistant-Addons"
}

locals {
  addons_data       = yamldecode(file("../addons.yml"))
  repository_topics = ["home-assistant-addon", "hacktoberfest"]
}

resource "github_repository" "addons" {
  for_each = local.addons_data["addons"]

  name = each.key

  has_issues      = true
  has_wiki        = false
  has_discussions = false
  has_projects    = false

  visibility = "public"
  topics     = concat(local.repository_topics, [each.key])

  delete_branch_on_merge = true
  allow_squash_merge     = false

  lifecycle {
    ignore_changes = [description, has_downloads]
  }
}
