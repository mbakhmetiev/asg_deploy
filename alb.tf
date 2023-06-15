resource "aws_alb" "example" {
  name               = "terraform-asg-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
  tags = {
    git_repo  = "mbakhmetiev/asg_deploy"
    yor_trace = "517e845b-9417-44cb-be79-2842581ca16e"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.example.arn
  port              = 80
  protocol          = "HTTP"
  # Will return following error if page not found
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "terraform-sg-alb"

  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.console_port
    to_port     = var.console_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    git_repo  = "mbakhmetiev/asg_deploy"
    yor_trace = "f8901c79-52ab-48b7-bbae-884ff711ee27"
  }
}

resource "aws_lb_target_group" "asg" {
  name        = "terraform-asg-tg"
  port        = var.server_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    git_repo  = "mbakhmetiev/asg_deploy"
    yor_trace = "42611037-07f7-43c1-b24e-b8e7f206395d"
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}