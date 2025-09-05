variable "title" {
  description = "The title of the line graph panel"
  type        = string
}

variable "line_color" {
  description = "The color of the line in the graph"
  type        = string
  default     = "blue"
}

variable "thresholds" {
  description = "List of thresholds for the graph"
  type        = list(object({
    value = number
    color = string
  }))
  default = []
}

variable "overlays" {
  description = "Additional attributes to override in the panel configuration"
  type        = any
  default     = {}
}

variable "datasource" {
  description = "The datasource for the panel"
  type        = string
  default     = "TestData CSV"
}

output "panel" {
  value = merge(
    jsondecode(templatefile("${path.module}/line_graph.json", {
      title       = var.title,
      line_color  = var.line_color,
      thresholds  = var.thresholds,
      datasource  = var.datasource
    })),
    var.overlays
  )
}