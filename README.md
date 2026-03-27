# Project: Webserver Cluster Module

This module deploys a production-ready web server cluster on AWS. It createsan Auto Scaling Group of EC2 instances running Nginx behind an Application 
Load Balancer, with separate security groups for the ALB and the instances so that your servers are never directly reachable from the internet. The ASG 
automatically replaces unhealthy instances and uses a rolling refresh strategy so deployments do not take down the entire fleet at once. 
This module currently has two versions (v0.0.1, v0.0.2).

### Usage Example for dev environment
```hcl
module "webserver_cluster" {
  source = "github.com/Damdam12345/day9-terraform-challenge//modules/services/web-cluster?ref=v0.0.2"
  cluster_name = "dev-cluster"
  vpc_id       = data.aws_vpc.default.id
  subnet_ids   = data.aws_subnets.default_vpc.ids
  server_port  = 80
```

### Usage Example for prod environment
```hcl
module "webserver_cluster" {
  source = "github.com/Damdam12345/day9-terraform-challenge//modules/services/web-cluster?ref=v0.0.1"
  cluster_name = "prod-cluster"
  vpc_id       = data.aws_vpc.default.id
  subnet_ids   = data.aws_subnets.default_vpc.ids
  server_port  = 80
```

## Required Inputs 
1. cluster_name - Name prefix applied to all resources created by this module
2. vpc_id - The ID of the VPC to deploy the cluster into 
3. subnet_ids - List of subnet IDs for the ASG instances
4. ami_id - The AMI ID to use for each EC2 instance
5. min_size -  Minimum number of instances in the ASG
6. max_size - Maximum number of instances in the ASG

## Limitations
1. Inline user data only: The module accepts a startup script through the `user_data` variable as an inline string.
2. Security groups uses inline block.

## Further Reading

Read the full article on Medium for more details:  
[Mastering Terraform Modules](https://medium.com/@onifadeayomide11/mastering-terraform-modules-versioning-pitfalls-and-scalable-multi-environment-design-5b1119ea58e8)
