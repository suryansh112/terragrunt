resource "aws_lb" "lb" {
  name               = "${var.env}-alb"
  internal           = var.lb_scheme_internal ? true : false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = var.public_subnet_ids

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "${var.env}-alb"
  #   enabled = true
  # }

  tags = {
    env = var.env
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    forward {
      target_group {
    arn = aws_lb_target_group.tg.arn
    weight = 100
      }
    }
  }
  depends_on = [aws_lb_target_group.tg]
}


resource "aws_lb_target_group" "tg" {
  name     = "${var.env}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.aws_vpc_name
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.env}-alb-sg"
  description = "${var.env}-ALB-security-group"
  vpc_id      = var.aws_vpc_name

  tags = {
    env = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_out" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}