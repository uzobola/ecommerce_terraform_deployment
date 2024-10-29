## This is the ROOT main.tf
##========> CREATE PROVIDER BLOCK
# Configure the AWS provider block. This tells Terraform which cloud provider to use and 
# how to authenticate (access key, secret key, and region) when provisioning resources.
# Note: Hardcoding credentials is not recommended for production use. Instead, use environment variables
# or IAM roles to manage credentials securely.

## PROVIDER CONFIGURATION
provider "aws" {
  access_key = var.aws_access_key          # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  secret_key = var.aws_secret_key         # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region     = var.region # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}


#  MODULE REFERENCES
# VPC Module
module "vpc" {
  source = "./modules/vpc"    # Path to your vpc module directory
  default_vpc_id = var.default_vpc_id   # For monitoring Server
  default_vpc_route_table_id = var.default_vpc_route_table_id   # For monitoring server


}

module "ec2" {
  source = "./modules/ec2"

  vpc_id             = module.vpc.vpc_id
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
  private_subnet_az1_id = module.vpc.private_subnet_az1_id
  private_subnet_az2_id = module.vpc.private_subnet_az2_id
  key_name            = var.key_name
  instance_type       = var.instance_type
  ami_id              = var.ami_id
}


# OUTPUTS
# All things Networking
output "vpc_details" {
  description = "VPC Details"
  value = {
    vpc_id            = module.vpc.vpc_id
    public_subnet_az1_id = module.vpc.public_subnet_az1_id
    public_subnet_az2_id = module.vpc.public_subnet_az2_id
    private_subnet_az1_id = module.vpc.private_subnet_az1_id
    private_subnet_az2_id = module.vpc.private_subnet_az2_id
    nat_gateway_ids   = module.vpc.nat_gateway_ids
    public_route_table_id = module.vpc.public_route_table_id
    private_route_table_ids = module.vpc.private_route_table_ids
  }
}

# Outputs all the Security Groups
output "security_groups" {
  description = "Security Group IDs"
  value = {
    alb      = module.ec2.security_group_ids.alb
    frontend = module.ec2.security_group_ids.frontend
    backend  = module.ec2.security_group_ids.backend
  }
}

# Outputs the ALB DNS name for application Access
output "alb_dns_name" {
  value       = module.ec2.alb_dns_name
  description = "The DNS name of the application load balancer"
}

# Outputs Frontend Public IP for SSH access
output "ecommerce_frontend_az1_public_ip" {
  value       = module.ec2.ecommerce_frontend_az1_public_ip
  description = "Public IP of frontend instance in AZ1"
}

output "ecommerce_frontend_az2_public_ip" {
  value       = module.ec2.ecommerce_frontend_az2_public_ip
  description = "Public IP of frontend instance in AZ2"
}

# Outputs Backend Private IPs for internal access
output "backend_private_ips" {
  description = "Private IPs of backend instances"
  value = {
    az1 = module.ec2.backend_private_ips.az1
    az2 = module.ec2.backend_private_ips.az2
  }
}


# Outputs Database endpoint
output "database_endpoint" {
  value       = module.ec2.rds_endpoint
  description = "The endpoint of the RDS database"
} 
