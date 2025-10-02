# Subnet group para RDS (usa las subredes privadas)
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "${var.project_name}-db-subnets" }
}

# RDS MariaDB compatible con Labs: clase t3.micro
resource "aws_db_instance" "mysql" {
  identifier                  = "${var.project_name}-mysql"
  engine                      = "mariadb"
  engine_version              = "10.6"         # deja major.minor; AWS elige el patch
  instance_class              = "db.t3.micro"  # <- CAMBIO CLAVE (antes: db.t2.micro)
  allocated_storage           = 20
  storage_type                = "gp2"
  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  db_subnet_group_name        = aws_db_subnet_group.db_subnets.name
  multi_az                    = false
  deletion_protection         = false
  storage_encrypted           = false
  skip_final_snapshot         = true
  auto_minor_version_upgrade  = true

  tags = { Name = "${var.project_name}-mysql" }
}



