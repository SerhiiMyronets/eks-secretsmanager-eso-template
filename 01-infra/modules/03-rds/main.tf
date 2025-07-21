locals {
  identifier = "${var.cluster_name}-db"
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.identifier}-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${local.identifier}-subnet-group"
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_+=<>?~"
}

resource "aws_db_instance" "this" {
  identifier             = local.identifier
  db_name                = var.rds_config.db_name
  username               = var.rds_config.db_username
  password               = random_password.db_password.result
  engine                 = var.rds_config.engine
  engine_version         = var.rds_config.engine_version
  instance_class         = var.rds_config.instance_class
  allocated_storage      = var.rds_config.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.this.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = local.identifier
  }
}

resource "aws_security_group" "this" {
  name        = "${local.identifier}-sg"
  description = "Allow DB access from allowed sources"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.identifier}-sg"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.rds_config.port
  to_port           = var.rds_config.port
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = var.private_subnet_cidrs
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_secretsmanager_secret" "db" {
  name        = "${local.identifier}-credentials"
  description = "Credentials for RDS instance ${local.identifier}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.rds_config.db_username
    password = random_password.db_password.result
    host     = aws_db_instance.this.address
    port     = var.rds_config.port
    dbname   = var.rds_config.db_name
  })
}