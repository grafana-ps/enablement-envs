// Create the cloud provider to load the stack
provider "grafana" {

  alias = "cloud"

  cloud_access_policy_token = var.cas_token
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
  auth = var.sa_token
}

module stack {

  source = "./resources"

  providers = {
    grafana = grafana.stack
  }
}