
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

variable "aws_security_group_protocol" {
    type = "string"
    #tcp
}

variable "db_multi_az" {
    type = "string"
    #false
}

variable "db_publicly_accessible" {
    type = "string"
    #true
}

variable "rds_subnet1" {
    default = "subnet-043c8689da63a7483"
}

variable "rds_subnet2" {
    default = "subnet-06a0d439f34fded46"
}

variable "vpc_id" {
    type = "string"
}

variable "subnetCidrBlock" {
    type = "list"
}
