provider "aws" {
    region = "us-east-2"
}

resource "aws_secretsmanager_secret" "team_1" {
  name = "grafana-team-1"
}

resource "aws_secretsmanager_secret_version" "team_1" {
  secret_id     = aws_secretsmanager_secret.team_1.id
  secret_string = jsonencode({
    team_1_sa_token = module.my_stack.team_1_sa_token
    team_1_cas_token = module.my_stack.team_1_cas_token
  })
}