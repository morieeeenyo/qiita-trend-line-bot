resource "aws_db_instance" "rds_instance" {
  identifier              = "rds-${var.name}"
  engine                  = "mysql"
  engine_version          = "8.0"
  db_name                 = "qiita_trend_line_bot_production"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "togomoriadmin"
  backup_retention_period = 0
  skip_final_snapshot     = true
  apply_immediately       = true
  allocated_storage       = 20

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group-${var.name}"
  description = "RDS security group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-${var.name}"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
}