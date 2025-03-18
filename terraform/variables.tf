variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "number_of_azs" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dockerhub_image" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "web_server_dockerhub_image" {
  description = "Docker Hub image for the web server"
  type        = string
}


variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}
