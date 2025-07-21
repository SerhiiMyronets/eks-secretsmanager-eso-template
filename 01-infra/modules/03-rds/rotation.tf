resource "aws_iam_role" "rotation" {
  name = "${local.identifier}-rotation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "rotation" {
  name        = "${local.identifier}-rotation-policy"
  description = "Policy for RDS secret rotation"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:GetRandomPassword"
        ],
        Resource = aws_secretsmanager_secret.db.arn
      },
      {
        Effect = "Allow",
        Action = [
          "rds-db:connect",
          "rds:DescribeDBInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rotation" {
  role       = aws_iam_role.rotation.name
  policy_arn = aws_iam_policy.rotation.arn
}

resource "aws_lambda_function" "rotation" {
  function_name = "${local.identifier}-rotation"
  handler       = "rotation.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.rotation.arn
  timeout       = 30

  filename         = "${path.module}/rotation.zip"
  source_code_hash = filebase64sha256("${path.module}/rotation.zip")

  vpc_config {
    subnet_ids         = var.db_subnet_ids
    security_group_ids = [aws_security_group.this.id]
  }

}


resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.db.arn
}

resource "aws_secretsmanager_secret_rotation" "db" {
  secret_id           = aws_secretsmanager_secret.db.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }

  depends_on = [
    aws_lambda_permission.allow_secretsmanager
  ]
}