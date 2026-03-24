terraform {
  #source = "${get_terragrunt_dir()}/../../../modules/load-balancer"
  source = "https://github.com/suryansh112/terragrunt.git//dev/modules/load-balancer?ref=v2.0"
}

dependency "vpc" {
    config_path = "../vpc"
     mock_outputs = {
      public_subnet_ids = ["subnet-id1234","subnet-id12345","subnet-id123456"]
      aws_vpc_id = "vpc-12345"
    }
}



inputs = {
  aws_vpc_name       = dependency.vpc.outputs.aws_vpc_id
  lb_scheme_internal = "false"
  public_subnet_ids  = dependency.vpc.outputs.public_subnet_ids
}