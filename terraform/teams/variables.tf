variable "slug" {
  description = "The slug of the stack"
}

variable "cas_token" {
  description = "The Cloud Access Policy Token for the stack"
  sensitive = true
}

variable "team_sa_token" {
  description = "The main Service Account Token for the stack"
  sensitive = true
}