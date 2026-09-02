variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_cidr_block" {
  description = "CIDR block of VPC"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnets" {
  description = "Config subnet per AZ"

  type = map(object({
    availability_zone = string
    public_cidr       = string
    private_db_cidr   = string
    private_app_cidr  = string
    reserva_cidr      = string
  }))
}
