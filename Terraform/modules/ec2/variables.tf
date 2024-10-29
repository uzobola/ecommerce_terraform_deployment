variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "instance_type"{
	default = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}


variable "public_subnet_az1_id" {
  description = "ID of public subnet in AZ1"
  type        = string
}

variable "public_subnet_az2_id" {
  description = "ID of public subnet in AZ2"
  type        = string
}

variable "private_subnet_az1_id" {
  description = "ID of private subnet in AZ1"
  type        = string
}

variable "private_subnet_az2_id" {
  description = "ID of private subnet in AZ2"
  type        = string
}


### For RDS
variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "ecommercedb"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "kurac5user"
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  default     = "kurac5password"
}