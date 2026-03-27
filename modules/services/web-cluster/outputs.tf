# output the DNS name of the load balancer
output "alb_dns_name" {
   value  = aws_lb.webserver.dns_name
}