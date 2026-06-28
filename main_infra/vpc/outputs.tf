output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private-subnets[*].id
}

output "nat_id" {
    value = aws_nat_gateway.nat.id
}