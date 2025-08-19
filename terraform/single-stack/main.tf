// Create the cloud provider to load the stack
provider "grafana" {

  alias = "cloud"

  cloud_access_policy_token = var.cas_token
}

// Create the stack provider with all the auth
provider "grafana" {

  alias = "stack"

  cloud_access_policy_token = var.cas_token
  
  // for stack resources
  url  = data.grafana_cloud_stack.stack.url
  auth = var.sa_token

  // for synthetic monitoring resources
  sm_access_token = var.sm_access_token
  sm_url          = var.sm_api_url

  // for k6s resources
  k6_access_token = var.k6_access_token

  // the other APIs can all share the same cloud access policy token
  cloud_provider_access_token = var.cas_token
  connections_api_access_token = var.cas_token
  fleet_management_auth = "${data.grafana_cloud_stack.stack.fleet_management_user_id}:${var.cas_token}"
  frontend_o11y_api_access_token = var.cas_token
}

data "grafana_cloud_stack" "stack" {
 slug = var.slug
 provider = grafana.cloud
}

module stack {

  source = "./resources"

  providers = {
    grafana = grafana.stack
  }
}