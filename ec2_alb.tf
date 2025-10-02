# AMI Amazon Linux 2 más reciente
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 3 instancias EC2 (una por AZ). Cada una corre un contenedor distinto.
resource "aws_instance" "web" {
  count                       = 3
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = element(aws_subnet.public[*].id, count.index) # reparte por AZ
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  # Script de arranque: instala Docker y levanta el contenedor
  user_data = <<-EOF
    #!/bin/bash
    set -xe
    yum update -y
    amazon-linux-extras install docker -y
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    # Imagen según el índice (element() = repartidor)
    IMAGE="${element(var.docker_images, count.index)}"

    # (Por si reinicia) elimina contenedor previo
    docker rm -f cheese || true

    docker run -d --name cheese -p 80:80 "$IMAGE"
  EOF

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
    # Condicional: la primera instancia IsPrimary=true, las demás=false
    IsPrimary = tostring(count.index == 0)
  }
}

# Target Group (lista de instancias) + health check
resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    path                = "/"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
  }

  tags = { Name = "${var.project_name}-tg" }
}

# Adjunta las 3 instancias al TG
resource "aws_lb_target_group_attachment" "attach" {
  count            = 3
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# ALB (balanceador) en subredes públicas
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = { Name = "${var.project_name}-alb" }
}

# Listener HTTP → reenvía al TG
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

