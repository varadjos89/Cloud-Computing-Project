# variable "cidrVpc" {
#     type = "string"
# }

# variable "vpcName" {
#     type = "string"
# }

variable "profile" {
    description = "Enter the environment (dev/prod):"
}

variable "region" {
    type = "string"
}

# variable "subnetCount" {
#     type = "string"
# }

# variable "routeTableName" {
#     type = "string"
# }

variable "subnetCidrBlock" {
    type = "list"
}

# variable "subnetZones" {
#     type = "list"
# }

# variable "internetGatewayName" {
#     type = "string"
# }

# variable "subnetName" {
#     type = "string"
# }

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

variable "vpc_id" {
    type = "string"
}

variable "db_skip_final_snapshot" {
    type = "string"
}

variable "s3_bucket" {
    type = "string"
}

variable "s3_acl" {
    type = "string"
}

variable "s3_force_destroy" {
    type = "string"
}

variable "s3_lifecycle_id" {
    type = "string"  
    #s3_lifecycle_id  
}

variable "s3_lifecycle_enabled" {
    type = "string"
    #true
}

# variable "s3_lifecycle_prefix" {
#     type = "string" 
#     #log/     
# }

variable "s3_lifecycle_transition_days" {
    type = "string"
    #30
}

variable "s3_lifecycle_transition_storage_class" {
    type = "string"
    #STANDARD_IA
}

variable "s3_bucket_name" {
    type = "string"
}

variable "ami" {
    type = "string"
}

variable "instance_type" {
    type = "string"
}

variable "disable_api_termination" {
    type = "string"
}

variable "volume_size" {
    type = "string"
}

variable "volume_type" {
    type = "string"
}

variable "delete_on_termination" {
    type = "string"
}

variable "key_name" {
    type="string"
}

variable "device_name" {
    type = "string"
}

variable "subnetZones" {
    type = "list"
}

variable "dynamoDB_name" {
    type = "string"
}

variable "dynamoDB_hashKey" {
    type = "string"
}

variable "dynamoDB_writeCapacity" {
    type = "string"
}

variable "dynamoDB_readCapacity" {
    type = "string"
}

variable "SGDatabase" {
    type = "string"
}

variable "SGApplication" {
    type = "string"
}

variable "rds_subnet_group_name" {
    type = "string"
}

variable "db_storage_type" {
    type = "string"
}

variable "db_allocated_storage" {
    type = "string"
}

variable "ec2_name" {
    type = "string"
}

variable "aws_region" {
  type="string"
}

variable "aws_accountid" {
    type="string"
}

variable "aws_application_name" {
  type="string"
}

variable "aws_application_group" {
  type="string"
}

variable "aws_circleci_user_name" {
  type="string"
}

variable "s3_bucket_name_application" {
  type="string"
}
