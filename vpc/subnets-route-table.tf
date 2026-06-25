
# subnet from the VPC - to be public 
resource "aws_subnet" "public-subnets" {
    count                   = length(var.PUBLIC_SUBNETS)
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = var.PUBLIC_SUBNETS[count.index]
    map_public_ip_on_launch = "true"
    availability_zone       = var.AVAILABILITY_ZONE[count.index]
    tags = {
      Name                                        = "${var.CLUSTER_NAME}-pub-subnet-${count.index}"
      ManagedBy                                   = "Terraform"
      "kubernetes.io/role/elb"                    = "1" # mark pub-subnet for LB 
      "kubernetes.io/cluster/${var.CLUSTER_NAME}" = "shared" # LB reference to which to connect
  }
}

resource "aws_subnet" "private-subnets" {
  count             = length(var.PRIVATE_SUBNETS)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.PRIVATE_SUBNETS[count.index]
  availability_zone = var.AVAILABILITY_ZONE[count.index]
  tags = {
      Name                                        = "${var.CLUSTER_NAME}-private-subnt-${count.index}"
      ManagedBy                                   = "Terraform"
      "kubernetes.io/role/internal-elb"           = "1" # mark pub-subnet for LB 
      "kubernetes.io/cluster/${var.CLUSTER_NAME}" = "shared" # LB reference to which to connect
  }
}

# routing table for public publishing
resource "aws_route_table" "main_public" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw_tf.id
    }
    tags = {
      Name = "${var.CLUSTER_NAME}-routetable-public"
      ManagedBy = "Terraform"
  }
}
resource "aws_route_table" "main_private" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = {
    Name = "${var.CLUSTER_NAME}-routetable-private"
    ManagedBy = "Terraform"
  }
}

# associate route table with subnet as public
resource "aws_route_table_association" "public-subnet-association" {
  count           = length(var.PUBLIC_SUBNETS)
  subnet_id       = aws_subnet.public-subnets[count.index].id
  route_table_id  = aws_route_table.main_public.id
}

# associate route table with subnet as private
resource "aws_route_table_association" "private-subnet-association" {
  count           = length(var.PRIVATE_SUBNETS)
  subnet_id       = aws_subnet.private-subnets[count.index].id
  route_table_id  = aws_route_table.main_private.id
}


