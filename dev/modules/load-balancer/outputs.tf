output "aws_alb_target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "aws_security_group_alb_id" {
  value = aws_security_group.alb_sg.id
}