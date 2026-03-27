# output the DNS name of the load balancer
output "alb_dns_name" {
   value  = aws_lb.webserver.dns_name
}

# Output the name of the Auto Scaling Group
output "asg_name" {
  value       = aws_autoscaling_group.webserver.name
}