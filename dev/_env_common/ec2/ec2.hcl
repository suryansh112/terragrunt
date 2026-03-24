terraform {
  #source = "${get_terragrunt_dir()}/../../../modules/ec2"
  source = "git::https://github.com/suryansh112/terragrunt.git//dev/modules/ec2?ref=v3.0"
}

dependency "vpc" {
    config_path = "../vpc"
    mock_outputs = {
      private_subnet_ids = ["subnet-id1234","subnet-12345","subnet-123456"]
      aws_vpc_id = "vpc-12345"
    }
}

dependency "loadbalancer" {
    config_path = "../load-balancer"
    mock_outputs = {
      aws_security_group_alb_id = "abcd-123"
      aws_alb_target_group_arn = "arn:12345"
    }
}

inputs = {
    azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
    aws_vpc_name = dependency.vpc.outputs.aws_vpc_id
    aws_security_group_alb_id = dependency.loadbalancer.outputs.aws_security_group_alb_id
    aws_alb_target_group_arn = dependency.loadbalancer.outputs.aws_alb_target_group_arn
    private_subnet_ids       = dependency.vpc.outputs.private_subnet_ids
}
