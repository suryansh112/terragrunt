variable "region" {
  type = string
}
variable "cidr_block" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "igw_name" {
  type = string
}

variable "ngw_name" {
  type = string
}

variable "enable_nat_gateway" {
  type = bool
}

variable "env" {
  type = string
}