// this creates a dashboard using the shared dashboard module
module "my_dashboard" {
  source = "../../modules/dashboard"

  dashboard_title   = "My Modular Dashboard"
  dashboard_tags    = ["example", "modular"]
  dashboard_timezone = "browser"
  time_from         = "now-7d"
  time_to           = "now"
  refresh_interval  = "5s"

  dashboard_panel_paths = [
    "${path.module}/mydashboard_panels/cpu_load.json",
    "${path.module}/mydashboard_panels/tickets_created.json",
    "${path.module}/mydashboard_panels/polystat.json"
  ]

  dashboard_panel_json = [
    module.cpu_load_panel_2.panel,
    module.memory_usage_panel.panel
  ]
}

// this creates a panel using the project-specific line graph template
module "cpu_load_panel_2" {
  source      = "./templates/line_graph"
  title       = "CPU Load 2"
  line_color  = "blue"
  thresholds  = [
    { value = 60, color = "yellow" },
    { value = 80, color = "red" }
  ]
  overlays = {
    gridPos = {
      h = 8
      w = 12
      x = 0
      y = 0
    },
    targets = [
      {
        refId       = "A",
        scenarioId  = "csv_metric_values",
        stringInput = "50,50,50,90,90,50,50"
      }
    ]
  }
}

// this creates another panel using the project-specific line graph template
module "memory_usage_panel" {
  source      = "./templates/line_graph"
  title       = "Memory Usage"
  line_color  = "green"
  thresholds  = [
    { value = 80, color = "orange" },
    { value = 90, color = "red" }
  ]
  overlays = {
    gridPos = {
      h = 8
      w = 12
      x = 12
      y = 0
    },
    targets = [
      {
        refId       = "B",
        scenarioId  = "csv_metric_values",
        stringInput = "30,40,50,60,70,80,90"
      }
    ]
  }
}