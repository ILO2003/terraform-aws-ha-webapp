output "alb_dns_name" {
  value       = aws_lb.ALB.dns_name
  description = "Internal ALB DNS of the Application Load Balancer"

}
output "vpc_id" {
  value       = aws_vpc.webapp-vpc.id
  sensitive   = false
  description = "ID of the HA web application VPC"
}
output "asg_name" {
  value       = aws_autoscaling_group.app_asg.name
  description = "Name of the application Auto Scaling Group"

}
output "target_group-arn" {
  value       = aws_lb_target_group.alb-target.arn
  description = "ARN of the ALB target group"

}
output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.alb-distribution.domain_name
  description = "Public CloudFront URL for the application"
}