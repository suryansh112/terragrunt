variable "env" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)

}
variable "lb_scheme_internal" {
  type = bool
}

variable "aws_vpc_name" {
  type = string
}