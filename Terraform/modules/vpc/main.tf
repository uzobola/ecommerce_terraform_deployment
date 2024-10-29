#This would contain all things networking
#- VPC
#- IGW
#- NAT Gateway
#- Public and Private Subnets
# Route Tables



# Create a VPC
resource "aws_vpc" "wl5vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "wl5vpc"
  }
}


# Availability Zone 1a:  Public Subnet 1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id     = aws_vpc.wl5vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true     # Makes subnet public/ Allosw to have a public IP

  tags = {
    Name = "public_subnet_az1"
  }
}


# Availability Zone 1b:  Public Subnet 2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id     = aws_vpc.wl5vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true     # Makes subnet public/ Allosw to have a public IP

  tags = {
    Name = "public_subnet_az2"
  }
}


# Add Internet Gateway
resource "aws_internet_gateway" "my_wl5_igw" {
  vpc_id = aws_vpc.wl5vpc.id

  tags = {
    Name = "my_wl5_igw"
  }
}


# Add Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.wl5vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_wl5_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Public Route Table Associations 
# Associate the Public Route Table with the Public Subnet AZ1a
resource "aws_route_table_association" "public_subnet_association_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

#Associate the Public Route Table with the Public Subnet AZ1b
resource "aws_route_table_association" "public_subnet_association_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}


# Availability Zone 1a:  Private Subnet 
resource "aws_subnet" "private_subnet_az1" {
  vpc_id     = aws_vpc.wl5vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_subnet_az1"
  }
}

# Availability Zone 1b:  Private Subnet 
resource "aws_subnet" "private_subnet_az2" {
  vpc_id     = aws_vpc.wl5vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private_subnet_az2"
  }
}



# Private Route Tables AZ1
resource "aws_route_table" "private_route_table_az1" {
  vpc_id = aws_vpc.wl5vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "private_route_table_az1"
  }
}

# Private Route Tables AZ2
resource "aws_route_table" "private_route_table_az2" {
  vpc_id = aws_vpc.wl5vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az2.id
  }

  tags = {
    Name = "private_route_table_az2"
  }
}



# Availability Zone 1: 
# Associate the Private Route Table with the Private Subnet
resource "aws_route_table_association" "private_subnet_association_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_route_table_az1.id

}

# Availability Zone 2: 
# Associate the Private Route Table with the Private Subnet
resource "aws_route_table_association" "private_subnet_association_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_route_table_az2.id

}


# Availability Zone 1a: 
# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip_az1" {
  domain = "vpc"
  
  tags = {
    Name = "nat_eip_az1"
  }
}


# Availability Zone 1a: 
# Create the NAT Gateway
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id  # Indicating that it has to be created on the public subnet

  depends_on = [aws_internet_gateway.my_wl5_igw]   # To ensure proper ordering, it is recommended to add an explicit dependency
                                            # on the Internet Gateway for the VPC.

tags = {
    Name = "nat_gateway_az1"
  }
}



#Availability Zone 1b: 
# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip_az2" {
  domain = "vpc"
  
  tags = {
    Name = "nat_eip_az2"
  }
}


# Availability Zone 1b: 
# Create the NAT Gateway
resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id  # Indicating that it has to be created on the public subnet

  depends_on = [aws_internet_gateway.my_wl5_igw]   # To ensure proper ordering, it is recommended to add an explicit dependency
  
tags = {
    Name = "nat_gateway_az2"
  }
}                                          # on the Internet Gateway for the VPC.



## Create VPC Peering so that Monitoring server can talk to the backend Servers in this VPC
# Create VPC Peering Connection
resource "aws_vpc_peering_connection" "monitoring_peer" {
  vpc_id        = aws_vpc.wl5vpc.id                    # Your VPC
  peer_vpc_id   = "vpc-09f5de1372b87abe5"                           # Monitoring Server's Default VPC ID
  auto_accept   = true                                # Since both VPCs are in your account

  tags = {
    Name = "vpcpeering-to-monitoring-vpc"
  }
}

# Add route from public subnet to monitoring VPC
# Only one route table entry since both share the same route table
resource "aws_route" "public_to_monitoring" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = "172.31.0.0/16"          # Monitoring Servers Default VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.monitoring_peer.id
}


# Add route from private subnet to monitoring VPC
resource "aws_route" "private_to_monitoring_az1" {
  route_table_id            = aws_route_table.private_route_table_az1.id
  destination_cidr_block    = "172.31.0.0/16"          # Default VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.monitoring_peer.id
}

resource "aws_route" "private_to_monitoring_az2" {
  route_table_id            = aws_route_table.private_route_table_az2.id
  destination_cidr_block    = "172.31.0.0/16"          # Default VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.monitoring_peer.id
}


# Add route in default VPC route table to reach your VPC
resource "aws_route" "monitoring_to_vpc" {
  route_table_id            = var.default_vpc_route_table_id
  destination_cidr_block    = "10.0.0.0/16"            # Your VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.monitoring_peer.id
}