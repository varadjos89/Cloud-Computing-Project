#data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "${var.cidrVpc}"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags = {
      Name = "${var.vpcName}"
  }
}

resource "aws_subnet" "main" {
  count = "${var.subnetCount}"
  availability_zone = "${var.subnetZones[count.index]}"
  cidr_block        = "${var.subnetCidrBlock[count.index]}"  
  vpc_id            = "${aws_vpc.main.id}"

  tags = {
      Name = "${var.subnetName}-${count.index}"
  }
}

resource "aws_internet_gateway" "main" {    
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.internetGatewayName}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags = {
      Name = "${var.routeTableName}"
  }
}

resource "aws_route_table_association" "main" {
  count = 3

 subnet_id      = "${aws_subnet.main.*.id[count.index]}"
 route_table_id = "${aws_route_table.main.id}"
}