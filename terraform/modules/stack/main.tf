resource "grafana_cloud_stack" "this" {
  name        = var.name
  slug        = var.slug
  region_slug = var.region
}

// Step 2: Create a service account and key for the stack
resource "grafana_cloud_stack_service_account" "cloud_sa" {
  stack_slug = grafana_cloud_stack.this.slug

  name        = "${var.name} service account"
  role        = "Admin"
  is_disabled = false
}

resource "grafana_cloud_stack_service_account_token" "cloud_sa" {
  stack_slug = grafana_cloud_stack.this.slug

  name               = "${var.name} cloud_sa key"
  service_account_id = grafana_cloud_stack_service_account.cloud_sa.id
}

resource "grafana_cloud_access_policy" "policy" {
  
  # prefix with stack name for uniqueness across stacks
  name   = "${grafana_cloud_stack.this.slug}-shared-policy"
  region = grafana_cloud_stack.this.region_slug

  scopes = flatten([
      var.fleet_management ? ["fleet-management:read", "fleet-management:write"] : [],
      var.connections || var.cloud_provider ? ["integration-management:read", "integration-management:write", "stacks:read"] : [],
      var.frontend_o11y ? ["frontend-observability:read", "frontend-observability:write", "frontend-observability:delete"] : []
    ])

  realm {
    type       = "stack"
    identifier = grafana_cloud_stack.this.id
  }
}

resource "grafana_cloud_access_policy_token" "cas_token" {
  
  name             = "${grafana_cloud_stack.this.slug}-shared-policy-token"
  region           = grafana_cloud_access_policy.policy.region
  access_policy_id = grafana_cloud_access_policy.policy.policy_id
}

output "sa_token" {
  value = grafana_cloud_stack_service_account_token.cloud_sa.key
  sensitive = true
}

output "cas_token" {
  value = grafana_cloud_access_policy_token.cas_token.token
  sensitive = true
}

output "this" {
  value = grafana_cloud_stack.this
  sensitive = true
}

