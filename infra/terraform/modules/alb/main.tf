resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnets_ids
  tags               = merge(var.tags, { Name = var.alb_name })
}

resource "aws_lb_target_group" "web" {
  name                 = "${var.alb_name}-tg"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = 10
  health_check {
    path              = var.health_check_path
    protocol          = "HTTP"
    matcher           = "200"
    interval          = 10
    healthy_threshold = 2
  }
  tags = merge(var.tags, { Name = "${var.alb_name}-tg" })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
