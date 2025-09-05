provider "aws" {
  region = "us-east-1"
}

data "aws_secretsmanager_secret_version" "grafana_team_1" {
  secret_id = "grafana-team-1"
}

locals {
  grafana_team_1_secret = jsondecode(data.aws_secretsmanager_secret_version.grafana_team_1.secret_string)
}

// Create the cloud provider to load the stack
provider "grafana" {

  alias = "cloud"

  cloud_access_policy_token = local.grafana_team_1_secret.team_1_cas_token
}

data "grafana_cloud_stack" "stack" {
 slug = var.slug
 provider = grafana.cloud
}

// Create the stack provider with all the auth
provider "grafana" {

  alias = "stack"

  // for stack resources
  url  = data.grafana_cloud_stack.stack.url
  auth = local.grafana_team_1_secret.team_1_sa_token
}

module stack {

  source = "./resources"

  providers = {
    grafana = grafana.stack
  }
}