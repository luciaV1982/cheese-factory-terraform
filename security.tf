# SG del ALB: abre HTTP al mundo (puerta 80 para cualquiera)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "HTTP publico al ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
}

# SG de EC2: HTTP solo desde el ALB + SSH solo desde tu IP
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "HTTP desde ALB y SSH desde mi IP"
  vpc_id      = aws_vpc.this.id

  # HTTP 80 solo desde el SG del ALB
  ingress {
    description     = "HTTP desde ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH solo tu IP/32
  ingress {
    description = "SSH desde mi IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "All egress (updates, docker pull)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-ec2-sg" }
}

# SG de RDS: permite MySQL solo desde las instancias EC2
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "MySQL solo desde EC2"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "MySQL desde EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-db-sg" }
}
