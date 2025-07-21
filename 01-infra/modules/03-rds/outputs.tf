output "db_credential_arns" {
  value = [aws_secretsmanager_secret.db.arn]
}