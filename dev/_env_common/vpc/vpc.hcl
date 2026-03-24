terraform {
  #source = "${get_terragrunt_dir()}/../../../modules/vpc"
  source = "https://github.com/suryansh112/terragrunt.git//modules/dev/vpc?ref=v1.0"
}

inputs = {
    cidr_block = "10.0.0.0/16"
    azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
    vpc_name             = "vpc"
    igw_name             = "igw"
    ngw_name             = "ngw"
    enable_nat_gateway   = "true"    
}