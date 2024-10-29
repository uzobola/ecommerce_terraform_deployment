#This would contain the 
#- EC2 instances
#- Security Groups
#- Application Load balancer



##### ADD Security Groups  ######################
#  Create a security group for the Application Load Balancer.
# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Allows HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   # Allows all outbound traffic
  }

  tags = {
    Name = "alb_sg"
  }
}


# Create a security group named that allows Frontend traffic.
resource "aws_security_group" "ecommerce_frontend_sg" {
  name        = "ecommerce_frontend_sg"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id
  
  
  # Ingress rules: Define inbound traffic that is allowed.Allow SSH traffic and HTTP traffic on port 8080 from any IP address (use with caution)
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description     = "ssh"
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["172.31.43.95/32"]
    description     = "Node Exporter metrics"
  }


  # Egress rules: Define outbound traffic that is allowed. The below configuration allows all outbound traffic from the instance.
  
  egress {
    from_port   = 0                 # Allows all outbound traffic (From port 0 to any port)
    to_port     = 0
    protocol    = "-1"               # "1" Means all protocols
    cidr_blocks = ["0.0.0.0/0"]     # Allow traffic to any IP address

  }  

  # Tags for the security group
  tags = {
    "Name"      : "ecommerce_frontend_sg"                          # Name tag for the security group
    "Terraform" : "true"                                # Custom tag to indicate this SG was created with Terraform
  }
}



# Create a security group named that manages Backend traffic.
# Backend Security Group
resource "aws_security_group" "ecommerce_backend_sg" {
  name        = "ecommerce_backend_sg"
  description = "Security group for backend servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.ecommerce_frontend_sg.id]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description     = "ssh"
  }

  # Node Exporter ingress rule
  ingress {
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
    description     = "Node Exporter metrics"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce_backend_sg"
    "Terraform" : "true"
  }
}




# Create 2 EC2 Instances in the Frontend Public Subnet
# ecommerce_frontend_az1
resource "aws_instance" "ecommerce_frontend_az1" {
  ami           = var.ami_id # Replace with your desired AMI
  instance_type = var.instance_type           # Change as needed
  subnet_id     = var.public_subnet_az1_id
  key_name      = var.key_name         # Specify your key pair name
  vpc_security_group_ids = [aws_security_group.ecommerce_frontend_sg.id]

  user_data     = file("${path.module}/scripts/frontend_userdata.sh") # path.module refers to the directory containing the module files, 
                                                                      # so this will correctly locate the scripts in my ec2 module's scripts directory.

  tags = {
    Name = "ecommerce_frontend_az1"
  }
}

# ecommerce_frontend_az2
resource "aws_instance" "ecommerce_frontend_az2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_az2_id
  vpc_security_group_ids = [aws_security_group.ecommerce_frontend_sg.id]
  key_name      = var.key_name
  user_data     = file("${path.module}/scripts/frontend_userdata.sh") # path.module refers to the directory containing the module files, 
                                                                      # so this will correctly locate the scripts in my ec2 module's scripts directory.

  tags = {
    Name = "ecommerce_frontend_az2"
  }
}



# Create 2 EC2 Instances in the Backend Public Subnet
# # ecommerce_backend_az1
resource "aws_instance" "ecommerce_backend_az1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_az1_id
  vpc_security_group_ids = [aws_security_group.ecommerce_backend_sg.id]
  key_name      = var.key_name
  user_data     = file("${path.module}/scripts/backend_userdata.sh")

  tags = {
    Name = "ecommerce_backend_az1"
  }
}

# # ecommerce_backend_az2
resource "aws_instance" "ecommerce_backend_az2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_az2_id
  vpc_security_group_ids = [aws_security_group.ecommerce_backend_sg.id]
  key_name      = var.key_name
  user_data     = file("${path.module}/scripts/backend_userdata.sh")

  tags = {
    Name = "ecommerce_backend_az2"
  }
}



# Create a Load Balancer
# Application Load Balancer
resource "aws_lb" "frontend_alb" {
  name               = "ecommerce-frontend-alb"
  internal           = false         # This is to ensure that it is internet facing
  load_balancer_type = "application"    
  security_groups    = [aws_security_group.alb_sg.id]    # Attaches the ALB to the security group
  subnets           = [var.public_subnet_az1_id, var.public_subnet_az2_id]    # Specifies the public subnets where the ALB would live

  tags = {
    Name = "ecommerce_frontend_alb"
  }
}



# ALB Target Group
# Defines where the ALB will route traffic
resource "aws_lb_target_group" "ecommerce_frontend_tg" {
  name     = "ecommerce-frontend-tg"
  port     = 3000              # Ports it would point to
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"   # Path to check the health of the application
    healthy_threshold   = 2     # Specifies the # of consecutive successful checks needed
    unhealthy_threshold = 10    # Specifies the # of consecutive failed checks needed
  }
}

# Create ALB Listener
resource "aws_lb_listener" "ecommerce_frontend" {
  load_balancer_arn = aws_lb.frontend_alb.arn      # Attach to the ALB
  port              = "80"                         # Specifies the port it should listen on
  protocol          = "HTTP"

  default_action {
    type             = "forward"                  # Specifies that it should forward to the target group
    target_group_arn = aws_lb_target_group.ecommerce_frontend_tg.arn
  }
}

# Create Target Group Attachments
resource "aws_lb_target_group_attachment" "ecommerce_frontend_az1" {
  target_group_arn = aws_lb_target_group.ecommerce_frontend_tg.arn
  target_id        = aws_instance.ecommerce_frontend_az1.id  # Attach to instance
  port             = 3000
}

resource "aws_lb_target_group_attachment" "ecommerce_frontend_az2" {
  target_group_arn = aws_lb_target_group.ecommerce_frontend_tg.arn
  target_id        = aws_instance.ecommerce_frontend_az2.id   # Attach to instance
  port             = 3000
}


# For RDS
resource "aws_db_instance" "postgres_db" {
  identifier           = "ecommerce-db"
  engine               = "postgres"
  engine_version       = "14.13"
  instance_class       = var.db_instance_class
  allocated_storage    = 20
  storage_type         = "standard"
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  parameter_group_name = "default.postgres14"
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "Ecommerce Postgres DB"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [var.private_subnet_az1_id, var.private_subnet_az2_id]  # Using existing private subnets in AZ1 and AZ2

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecommerce_backend_sg.id]  # Using your existing backend security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}





# Outputs are displayed at the end of the 'terraform apply' command and can be accessed using `terraform output`.
# They are useful for sharing information about your infrastructure that you may need later (e.g., IP addresses, DNS names).
output "ecommerce_frontend_az1_public_ip" {
  value       = aws_instance.ecommerce_frontend_az1.public_ip
  description = "The public IP address of the AZ1 frontend server."
}

output "ecommerce_frontend_az2_public_ip" {
  value       = aws_instance.ecommerce_frontend_az2.public_ip
  description = "The public IP address of the AZ2 frontend server."
}

# More outputs
output "alb_dns_name" {
  value       = aws_lb.frontend_alb.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "backend_private_ips" {
  value = {
    az1 = aws_instance.ecommerce_backend_az1.private_ip
    az2 = aws_instance.ecommerce_backend_az2.private_ip
  }
  description = "Private IPs of backend instances"
}

output "security_group_ids" {
  value = {
    alb      = aws_security_group.alb_sg.id
    frontend = aws_security_group.ecommerce_frontend_sg.id
    backend  = aws_security_group.ecommerce_backend_sg.id
  }
  description = "IDs of all security groups"
}

output "target_group_arn" {
  value       = aws_lb_target_group.ecommerce_frontend_tg.arn
  description = "ARN of the frontend target group"
}


output "rds_endpoint" {
  value = aws_db_instance.postgres_db.endpoint
}