###
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = "${get_terragrunt_dir()}/../../../_env_common/ec2/ec2.hcl"
}
inputs = {
    ami_id                   = "ami-02777684819ca2214"
    env                      = "dev"
}