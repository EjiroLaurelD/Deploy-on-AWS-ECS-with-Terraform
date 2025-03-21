resource "aws_lb" "main_lb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_alb_target_group" "my_ecs_target_group" {
  name        = "spendsmart-fe-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  #deregistration_delay = "5"

  health_check {
    healthy_threshold   = "3"
    interval            = "10"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    port                = "3000"
    path                = "/"
    unhealthy_threshold = "2"
  }
  depends_on = [
    aws_lb.main_lb
  ]

}

resource "aws_lb_target_group" "python_backend_tg" {
  name                 = "backend-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = "5"

  health_check {
    path                = "/"
    interval            = "20"
    timeout             = "5"
    protocol            = "HTTP"
    port                = "5000"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
    matcher             = "200"
  }

  depends_on = [
    aws_lb.main_lb
  ]

}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = "443"
  protocol          = "HTTPS"


  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "okay"
      status_code  = "200"
    }
  }
  #default_action {
  # target_group_arn = aws_alb_target_group.my_ecs_target_group.arn
  # type             = "forward"
  #}
}

resource "aws_lb_listener_rule" "react_app" {
  listener_arn = aws_alb_listener.https.arn
  priority     = "100"

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.my_ecs_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/frontend*"]
    }
  }

}

resource "aws_lb_listener_rule" "python_backend" {
  listener_arn = aws_alb_listener.https.arn
  priority     = "100"

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.python_backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/backend*"]
    }
  }

}
