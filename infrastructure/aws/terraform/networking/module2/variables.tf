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

variable "aws_security_group_protocol" {
    type = "string"
    #tcp
}

variable "db_instance" {
    type = "string"
    #db.t2.micro
}

variable "db_username" {
    type = "string"
}

variable "db_password" {
    type = "string"
}

variable "db_identifier" {
    type = "string"     
    #csye6225-fall2019
}

variable "db_engine" {
    type = "string"
    #mysql
}

variable "db_name" {
    type = "string"
    #csye6225
}

variable "db_engine_version" {
    type = "string"
    #to be found and hardcoded
}

variable "db_multi_az" {
    type = "string"
    #false
}

variable "db_publicly_accessible" {
    type = "string"
    #true
}
