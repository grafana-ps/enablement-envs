terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.25"
    }
  }
}

variable "dashboard_title" {
  description = "The title of the Grafana dashboard"
  type        = string
}

variable "dashboard_tags" {
  description = "Tags for the Grafana dashboard"
  type        = list(string)
  default     = []
}

variable "dashboard_timezone" {
  description = "Timezone for the Grafana dashboard"
  type        = string
  default     = "browser"
}

variable "time_from" {
  description = "Start time for the dashboard"
  type        = string
  default     = "now-7d"
}

variable "time_to" {
  description = "End time for the dashboard"
  type        = string
  default     = "now"
}

variable "refresh_interval" {
  description = "Refresh interval for the dashboard"
  type        = string
  default     = "5s"
}

variable "dashboard_panel_paths" {
  description = "List of file paths to the panel JSON files"
  type        = list(string)
  default     = []
}

variable "dashboard_panel_json" {
  description = "List of panels already in JSON format"
  type        = list(any)
  default     = []
}

resource "grafana_dashboard" "dashboard" {
  config_json = templatefile("${path.module}/dashboard.json", {
    dashboard_title   = var.dashboard_title,
    dashboard_tags    = var.dashboard_tags,
    dashboard_timezone = var.dashboard_timezone,
    time_from         = var.time_from,
    time_to           = var.time_to,
    refresh_interval  = var.refresh_interval,
    dashboard_panels  = concat(
      [for path in var.dashboard_panel_paths : jsondecode(file(path))],
      var.dashboard_panel_json
    )
  })
}