// Create a stack
module "stack_1" {
  source = "../modules/stack"

  root_token = var.cloud_access_policy_token

  name = "Matt Rethers TF Stack 1"
  slug = "mrtfstack1"
  
  synthetics = true
  k6 = true
  oncall = true
  connections = true
  fleet_management = true
  app_o11y = true
  cloud_provider = true
  frontend_o11y = true

  providers = {
    grafana = grafana.cloud
  }
}

// Create the stack provider with all the auth (except cloud)
provider "grafana" {

  alias = "my_stack_provider"

  cloud_access_policy_token = module.stack_1.cas_token

  // for stack resources
  url  = module.stack_1.this.url
  auth = module.stack_1.sa_token

  // for synthetic monitoring resources
  sm_access_token = module.stack_1.sm_installation.sm_access_token
  sm_url          = module.stack_1.sm_installation.stack_sm_api_url

  // for k6s resources
  k6_access_token = module.stack_1.k6_installation.k6_access_token

  // the other APIs can all share the same cloud access policy token

#   oncall_access_token =
  cloud_provider_access_token = module.stack_1.cas_token
  connections_api_access_token = module.stack_1.cas_token
  fleet_management_auth = "${module.stack_1.this.fleet_management_user_id}:${module.stack_1.cas_token}"
  frontend_o11y_api_access_token = module.stack_1.cas_token
}

module "my_stack" {
    source = "./my_stack"
    stack = module.stack_1.this
    region = module.stack_1.region
    providers = {
      grafana = grafana.my_stack_provider
    }
}

output "stack_1" {
  value = module.stack_1
  sensitive = true
}

output "team_1_sa_token" {
  value = module.my_stack.team_1_sa_token
  sensitive = true
}

output "team_1_cas_token" {
  value = module.my_stack.team_1_cas_token
  sensitive = true
}