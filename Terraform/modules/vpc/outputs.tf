# This is saying , when you create the VPC, i want you to output this
# because another module is going to need it later.
# The root main.tf sees everything so when we call it here
# the rootmain can call it and use whatever dependencies are needed.

output "vpc_id" {
 value = aws_vpc.wl5vpc.id    #reference the offical name of the resource. 
                                 # The rest would pop-up
}

output "public_subnet_az1_id" {
  value = aws_subnet.public_subnet_az1.id
}

output "public_subnet_az2_id" {
  value = aws_subnet.public_subnet_az2.id
}

output "private_subnet_az1_id" {
  value = aws_subnet.private_subnet_az1.id
}

output "private_subnet_az2_id" {
  value = aws_subnet.private_subnet_az2.id
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways"
  value = {
    az1 = aws_nat_gateway.nat_gateway_az1.id
    az2 = aws_nat_gateway.nat_gateway_az2.id
  }
}

output "public_route_table_id" {
  description = "Public route table"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table_ids" {
  description = "The IDs of the private route tables"
  value = {
    az1 = aws_route_table.private_route_table_az1.id
    az2 = aws_route_table.private_route_table_az2.id
  }
}