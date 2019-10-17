variable "cidrVpc" {
    type = "string"
}

variable "vpcName" {
    type = "string"
}

variable "profile" {
    description = "Enter the environment (dev/prod):"
}

variable "region" {
    type = "string"
}

variable "subnetCount" {
    type = "string"
}

variable "routeTableName" {
    type = "string"
}

variable "subnetCidrBlock" {
    type = "list"
}

variable "subnetZones" {
    type = "list"
}

variable "internetGatewayName" {
    type = "string"
}

variable "subnetName" {
    type = "string"
}