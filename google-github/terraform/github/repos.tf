terraform {
  backend "gcs" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    prefix = "terraform/github/terraform.tfstate"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.17.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
}

module "gitops" {
  source = "./modules/repository"

  repo_name          = "<GITOPS_REPOSITORY_NAME>"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}

resource "github_repository_webhook" "gitops_atlantis_webhook" {
  repository = module.gitops.repo_name

  configuration {
    url          = "<GITOPS_REPO_ATLANTIS_WEBHOOK_URL>"
    content_type = "json"
    insecure_ssl = false
    secret       = var.atlantis_repo_webhook_secret
  }

  active = true

  events = ["pull_request_review", "push", "issue_comment", "pull_request"]
}
variable "atlantis_repo_webhook_secret" {
  type    = string
  default = ""
}

module "metaphor" {
  source = "./modules/repository"

  repo_name          = "<METAPHOR_REPOSITORY_NAME>"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = true
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}
