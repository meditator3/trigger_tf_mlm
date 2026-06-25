# internet gateway for internet 
resource "aws_internet_gateway" "gw_tf" {
    vpc_id = aws_vpc.main_vpc.id
    tags   = {
        Name = "${var.CLUSTER_NAME}-igw"
        ManagedBy = "Terraform"
    }
}
# VPC network
resource "aws_vpc" "main_vpc" {
    cidr_block              =  var.VPC_CIDR
    instance_tenancy        = "default"
    enable_dns_hostnames    = "true"
    enable_dns_support      = "true"
    tags = {
    Name = "${var.CLUSTER_NAME}-vpc"
    ManagedBy = "Terraform"
  }
}
# assign eip for nat to serve
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnets[0].id
  single_nat_gateway = true  
  one_nat_gateway_per_az = false
  tags = {
    Name = "${var.CLUSTER_NAME}-nat"
    ManagedBy = "Terraform"
  }

  depends_on = [aws_internet_gateway.gw_tf]
}













# this gets list of  all public ip's available for telaviv
# data "aws_ip_ranges" "telaviv_range" {
#     regions = var.AWS_REGION
#     services = ["ec2"]

# }
# extracting list of cidr blocks from that list of public ip's
# resource "aws_route_table" "k3s_rt" {
#     vpc_id = aws_default_vpc.default.id
#     route {
#         cidr_block = slice(data.aws_ip_ranges.telaviv_range.cidr_blocks, 0, 50)
#     }
# }