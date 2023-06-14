resource "aws_launch_configuration" "example" {
  image_id      = data.aws_ami.ubu22.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.asg.id]

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "*** ASG server instance ***" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  max_size = 10
  min_size = 2

  tag {
    key = "Name"
    value = "terraform-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "asg" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}