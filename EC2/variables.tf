variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0842c40ebfd285cd0"
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
  default     = ["subnet-0ccf0feec461d7c9b", "subnet-01354e69cd2c6142e"]
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-006ec002b74f6c066"
}