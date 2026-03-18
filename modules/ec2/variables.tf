variable "ami_id" {
  type = string
}
variable "azs" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)

}

variable "env" {
  type = string
}

variable "aws_vpc_name" {
  type = string
}

variable "aws_alb_target_group_arn" {
  type = string
}

variable "aws_security_group_alb_id"{
  type = string
}
