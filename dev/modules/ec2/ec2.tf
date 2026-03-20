locals {
  asg_name             = "${var.env}-asg"
  launch_template_name = "${var.env}-template"
  ec2_name_prefix      = "${var.env}-ec2"
  ec2_tags = [
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    }
  ]
}

resource "aws_launch_template" "main" {
  name_prefix   = "${local.ec2_name_prefix}-"
  image_id      = var.ami_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  instance_type = "t3.micro"
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_ssm_profile.arn
  }
  user_data     = base64encode(file("${path.module}/user_data.sh"))
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name                = local.asg_name
  desired_capacity    = 1
  max_size            = 1
  min_size            = 0
  target_group_arns   = [var.aws_alb_target_group_arn]
  health_check_type   = "ELB"
  vpc_zone_identifier = var.private_subnet_ids
  

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]

    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 300
    }
  }
  dynamic "tag" {
    for_each = local.ec2_tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
}



resource "aws_iam_role" "ec2_ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.env}-ec2-sg"
  description = "${var.env}-EC2-security-group"
  vpc_id      = var.aws_vpc_name

  tags = {
    env = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_strapi_http" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = "tcp"
  from_port         = 1337
  to_port           = 1337
  referenced_security_group_id = var.aws_security_group_alb_id
}

resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  referenced_security_group_id = var.aws_security_group_alb_id
}


resource "aws_vpc_security_group_egress_rule" "ec2_all_out" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}