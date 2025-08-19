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

variable "sm_access_token" {
  description = "the synthetic monitoring token"
  sensitive = true
}

variable "sm_api_url" {
  description = "the synthetic monitoring installation"
}

variable "k6_access_token" {
  description = "the k6 access token"
  sensitive = true
}