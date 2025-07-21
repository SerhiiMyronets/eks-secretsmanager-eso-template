# 1. Archive Lambda source code

data "archive_file" "rotation" {
  type        = "zip"
  source_file = "${path.module}/templates/rotation.py"
  output_path = "${path.module}/lambda/rotation.zip"
}

# 2. IAM Role for Lambda
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

# 3. IAM Policy for RDS rotation
resource "aws_iam_policy" "rotation" {
  name        = "${local.identifier}-rotation-policy"
  description = "Policy for RDS secret rotation"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
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
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rotation" {
  role       = aws_iam_role.rotation.name
  policy_arn = aws_iam_policy.rotation.arn
}

# 4. Lambda Function for rotation
resource "aws_lambda_function" "rotation" {
  function_name = "${local.identifier}-rotation"
  handler       = "rotation.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.rotation.arn
  timeout       = 30

  filename         = data.archive_file.rotation.output_path
  source_code_hash = data.archive_file.rotation.output_base64sha256

  vpc_config {
    subnet_ids         = var.db_subnet_ids
    security_group_ids = [aws_security_group.this.id]
  }
}

# 5. Attach Lambda to Secret for rotation
resource "aws_secretsmanager_secret_rotation" "db" {
  secret_id           = aws_secretsmanager_secret.db.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn
  rotation_rules {
    automatically_after_days = 30
  }
}
