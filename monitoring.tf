resource "aws_cloudwatch_metric_alarm" "hawebapp" {
  alarm_name        = "alb-alarm"
  alarm_description = "Triggers when ALB healthy targets drop below 2"
  namespace         = "AWS/ApplicationELB"
  metric_name       = "HealthyHostCount"
  dimensions = {
    TargetGroup  = aws_lb_target_group.alb-target.arn_suffix
    LoadBalancer = aws_lb.ALB.arn_suffix
  }
  comparison_operator = "LessThanThreshold"
  threshold           = 2
  evaluation_periods  = 2
  period              = 60
  statistic           = "Minimum"
}

resource "aws_cloudwatch_dashboard" "hawebapp" {
  dashboard_name = "ha-webapp-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup",
              aws_lb_target_group.alb-target.arn_suffix,
              "LoadBalancer",
              aws_lb.ALB.arn_suffix
            ]
          ]

          period = 60
          stat   = "Minimum"
          region = var.aws_region
          title  = "ALB Healthy Targets"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              aws_autoscaling_group.app_asg.name
            ]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "ASG CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              aws_db_instance.main-db-instance.identifier
            ]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "RDS CPU Utilization"
        }
      }
    ]

  })
}