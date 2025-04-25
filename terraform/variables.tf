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

