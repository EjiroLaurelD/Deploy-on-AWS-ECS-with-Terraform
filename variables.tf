variable "region" {
  type = string 
  default = "eu-west-2"
}

variable "vpc_cidr" {
  type = string
  description = "VPC cidr"
  default = "10.0.0.0/16"
}

variable "vpc_azs" {
  type = list(string)
  description = "Availability zones for VPC"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "private_subnets" {
  type = list(string)
  description = "Private subnets inside the VPC"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type = list(string)
  description = "Public subnets inside the VPC"
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
