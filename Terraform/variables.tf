# Here we are describing the variables

variable "access_key" { 
	type=string
	sensitive=true
	}
          
variable "secret_key"{ 
    type=string         
	sensitive = true
	}
  
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
} 

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

 variable "monitoring_server_ip" {
   description = "IP address of the monitoring server"
   type        = string
 }

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS
}

variable "default_vpc_id" {
  description = "Defualt VPC ID for Monitoring Server"
  type        = string
}

variable "default_vpc_route_table_id" {
  description = "Defualt VPC route table ID for Monitoring Server"
  type        = string
}