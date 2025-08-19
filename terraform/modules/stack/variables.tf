variable "root_token" {
    description = "a cloud access policy token with permissions to create stacks"
    sensitive = true
}

variable "name" {
    description = "the display name for the stack"
}

variable "slug" {
    description = "the short name for the stack"
}

variable "region" {
    description = "the region where the stack is deployed"
    default = "us"
}

output "region" {
  value = var.region
}

variable "synthetics" {}
variable "k6" {}
variable "oncall" {}
variable "connections" {}
variable "fleet_management" {}
variable "app_o11y" {}
variable "cloud_provider" {}
variable "frontend_o11y" {}