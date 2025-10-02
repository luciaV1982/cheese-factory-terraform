output "alb_dns_name" {
  description = "URL del Application Load Balancer (abre en el navegador)"
  value       = aws_lb.alb.dns_name
}

output "web_instance_public_ips" {
  description = "IPs públicas de las 3 instancias EC2"
  value       = [for i in aws_instance.web : i.public_ip]
}

output "rds_endpoint" {
  description = "Endpoint de MySQL (accesible solo desde las EC2)"
  value       = aws_db_instance.mysql.address
  sensitive   = true
}
