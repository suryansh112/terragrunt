locals {
    ### Load account and region variables
    account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    aws_account_id  = local.account_vars.locals.aws_account_id
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = "agentcore-chatbot-prod-static-730335384723"

    key            = "${path_relative_to_include()}/terragrunt.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

inputs = {
  region = "us-east-1"
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${local.aws_account_id}:role/test-terragrunt-role"
  }
}

EOF
}
