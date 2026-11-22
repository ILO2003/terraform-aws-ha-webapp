resource "aws_lb" "ALB" {
  name               = "HA-webapp-ALB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB-SG.id]
  subnets            = [aws_subnet.private-app-subnet-az1.id, aws_subnet.private-app-subnet-az2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "Prod"
  }
}

resource "aws_lb_target_group" "alb-target" {
  name        = "ALB-tg-to-APP"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.webapp-vpc.id
  health_check {
    path     = "/health"
    protocol = "HTTP"
    port     = "traffic-port"
    matcher  = "200"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target.arn
  }
}

#My own launch template to spin up the website specifying user data.
resource "aws_launch_template" "ha-webapp-template" {
  name                                 = "webapp-template"
  image_id                             = "ami-0f71b90bee7050a75"
  instance_type                        = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.APP-SG.id]
  }
  user_data = filebase64("${path.module}/userdata.sh")
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "private-app-asg"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier = [
    aws_subnet.private-app-subnet-az1.id,
    aws_subnet.private-app-subnet-az2.id
  ]
  target_group_arns = [aws_lb_target_group.alb-target.arn]
  launch_template {
    id      = aws_launch_template.ha-webapp-template.id
    version = aws_launch_template.ha-webapp-template.latest_version

  }
}

#In case CPU utilization goes over 75% -> spin up one more EC2 instance
resource "aws_autoscaling_policy" "app-asg-policy" {
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  name                   = "app-scaling-policy"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }

}
