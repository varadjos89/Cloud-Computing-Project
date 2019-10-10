variable "cidrVpc" {
    description = "Enter cidr vpc value"
    type =  "string"
}

variable "vpcName" {
    description = "Enter VPC Name"
    type = "string"
}

variable "region" {
    description = "Enter region"
    type = "string"
}

variable "profile" {
    description = "Enter Profile"
    type = "string"
}

variable "internetGatewayName" {
    description = "Enter internet gateway name"
    type = "string"
}

variable "subnetCidrBlock" {
    description = "Enter subnet cidr block value"
    type = "list"
}

variable "routeTableName" {
    description = "Enter route table name"
    type = "string"
}

variable "subnetName" {
    description = "Enter subnet Name"
    type = "string"
}
