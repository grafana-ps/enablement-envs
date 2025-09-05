// create a team
resource "grafana_team" "editor_team" {
  name = "team-1"
}

// create a service account for that team
resource "grafana_service_account" "editor_sa" {
  name = "team-1"
  role = "Editor"
}

// create a custom role for that team
resource "grafana_role" "custom_editor" {
  name        = "custom_editor"
  description = "Custom role with editor-like permissions"
  version     = 1
  global      = true

  permissions {
    action = "dashboards:create"
    scope  = "folders:*"
  }
  permissions {
    action = "dashboards:read"
    scope  = "folders:*"
  }
  permissions {
    action = "dashboards:write"
    scope  = "folders:*"
  }
  permissions {
    action = "dashboards:delete"
    scope  = "folders:*"
  }
  permissions {
    action = "annotations:create"
    scope  = "folders:*"
  }
  permissions {
    action = "annotations:read"
    scope  = "folders:*"
  }
  permissions {
    action = "annotations:write"
    scope  = "folders:*"
  }
  permissions {
    action = "annotations:delete"
    scope  = "folders:*"
  }
  permissions {
    action = "folders:create"
    scope  = "folders:*"
  }
  permissions {
    action = "folders:read"
    scope  = "folders:*"
  }
  permissions {
    action = "folders:write"
    scope  = "folders:*"
  }
  permissions {
    action = "folders:delete"
    scope  = "folders:*"
  }
  permissions {
    action = "alert.rules:create"
    scope  = "folders:*"
  }
  permissions {
    action = "alert.rules:read"
    scope  = "folders:*"
  }
  permissions {
    action = "alert.rules:write"
    scope  = "folders:*"
  }
  permissions {
    action = "alert.rules:delete"
    scope  = "folders:*"
  }
  permissions {
    action = "alert.silences:create"
    scope  = "folders:*"
  }
  permissions {
    action = "alert.silences:read"
    scope  = "folders:*"
  }
  permissions {
    action = "alert.silences:write"
    scope  = "folders:*"
  }
  permissions {
    action = "datasources:explore"
  }
  permissions {
    action = "library.panels:create"
    scope  = "folders:*"
  }
  permissions {
    action = "library.panels:read"
    scope  = "folders:*"
  }
  permissions {
    action = "library.panels:write"
    scope  = "folders:*"
  }
  permissions {
    action = "library.panels:delete"
    scope  = "folders:*"
  }
}

// assign the role to the team
resource "grafana_role_assignment" "editor_role_assignment_team" {
  role_uid = grafana_role.custom_editor.uid
  teams    = [grafana_team.editor_team.id]
  service_accounts = [grafana_service_account.editor_sa.id]
}

// create a service account token for the team
resource "grafana_service_account_token" "editor_sa_token" {
  name              = "team-1-editor-sa-token"
  service_account_id = grafana_service_account.editor_sa.id
}

// create a cloud access policy for the stack
resource "grafana_cloud_access_policy" "team_1_policy" {
  name   = "team-1-policy"
  region = var.region
  scopes = ["stacks:read"]
  realm {
    type = "stack"
    identifier = var.stack.id
  }
}

// create a token for the cloud access policy
resource "grafana_cloud_access_policy_token" "team_1_policy_token" {
  name               = "team-1-policy-token"
  region             = var.region
  access_policy_id   = grafana_cloud_access_policy.team_1_policy.policy_id
}

// return the SA token as output so it can be shared with other teams
output "team_1_sa_token" {
    value = grafana_service_account_token.editor_sa_token.key
    sensitive = true
}

output "team_1_cas_token" {
    value = grafana_cloud_access_policy_token.team_1_policy_token.token
    sensitive = true
}