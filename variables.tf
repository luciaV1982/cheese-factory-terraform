# Región de AWS
variable "region" {
  description = "Región AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

# Nombre del proyecto (se usará como prefijo en recursos)
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "cheese-factory"
}

# CIDR de la VPC (barrio completo)
variable "vpc_cidr" {
  description = "CIDR para la VPC"
  type        = string
  default     = "10.10.0.0/16"
}

# IP pública del usuario para acceso SSH
variable "my_ip" {
  description = "IP pública desde donde se permite acceso SSH (en formato CIDR /32)"
  type        = string
}

# Nombre del Key Pair en AWS
variable "key_name" {
  description = "Nombre del Key Pair en AWS para SSH"
  type        = string
}

# Tipo de instancia EC2
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

# Imágenes Docker para cada instancia
variable "docker_images" {
  description = "Lista de imágenes Docker para cada instancia EC2"
  type        = list(string)
}

# Usuario de la base de datos
variable "db_username" {
  description = "Usuario para la base de datos RDS"
  type        = string
  sensitive   = true
}

# Password de la base de datos
variable "db_password" {
  description = "Password de la base de datos RDS"
  type        = string
  sensitive   = true
}

# Nombre de la base de datos
variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "cheesedb"
}
