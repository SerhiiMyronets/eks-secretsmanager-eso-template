# resource "aws_secretsmanager_secret" "db" {
#   name        = "${local.identifier}-credentials"
#   description = "Credentials for RDS instance ${local.identifier}"
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }

data "aws_secretsmanager_secret" "db" {
  name = "${local.identifier}-credentials"
}

locals {
  secret_id  = data.aws_secretsmanager_secret.db.id
  secret_arn = data.aws_secretsmanager_secret.db.arn
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = local.secret_id
  secret_string = jsonencode({
    username = var.rds_config.db_username
    password = random_password.db_password.result
    engine   = var.rds_config.engine
    host     = aws_db_instance.this.address
    port     = var.rds_config.port
    dbname   = var.rds_config.db_name
  })
}