// Create a stack
module "stack_2" {
  source = "../modules/stack"

  root_token = var.cloud_access_policy_token

  name = "Matt Rethers TF Stack 2"
  slug = "mrtfstack2"
  
  synthetics = false
  k6 = false
  oncall = false
  connections = false
  fleet_management = false
  app_o11y = false
  cloud_provider = false
  frontend_o11y = false

  providers = {
    grafana = grafana.cloud
  }
}

// Create the stack provider with all the auth (except cloud)
provider "grafana" {

  alias = "my_stack_provider_2"
  
  // for stack resources
  url  = module.stack_2.this.url
  auth = module.stack_2.sa_token

  // for synthetic monitoring resources
  sm_access_token = module.stack_2.sm_installation.sm_access_token
  sm_url          = module.stack_2.sm_installation.stack_sm_api_url

  // for k6s resources
  k6_access_token = module.stack_2.k6_installation.k6_access_token

  // the other APIs can all share the same cloud access policy token

#   oncall_access_token =
  cloud_provider_access_token = module.stack_2.cas_token
  connections_api_access_token = module.stack_2.cas_token
  fleet_management_auth = "${module.stack_2.this.fleet_management_user_id}:${module.stack_2.cas_token}"
  frontend_o11y_api_access_token = module.stack_2.cas_token
}

module "my_stack_2" {
    source = "./my_stack_2"
    stack = module.stack_2.this
    region = module.stack_2.region
    providers = {
      grafana = grafana.my_stack_provider_2
    }
}

output "stack_2" {
  value = module.stack_2
  sensitive = true
}