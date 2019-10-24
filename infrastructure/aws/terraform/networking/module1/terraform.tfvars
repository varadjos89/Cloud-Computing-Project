vpcName = "myModule1Vpc"
region = "us-east-1"
subnetName = "myModule1Subnet"
subnetCount = "3"
internetGatewayName = "myModule1IG"
routeTableName = "myModule1RT"
cidrVpc = "10.0.0.0/16"
subnetCidrBlock = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
subnetZones = ["us-east-1a","us-east-1b","us-east-1c"]

SGDatabase                              = "DatabaseDevOne"
SGApplication                           = "ApplicationDevOne"


# vpc_id                                  = "$"
aws_security_group_protocol             = "tcp"
db_name                                 = "csye6225DB"  
db_engine                               = "mysql"  
db_engine_version                       = "5.7"
db_instance                             = "db.t2.medium"
db_multi_az                             = "false"
db_identifier                           = "csye6225-dev1"
db_username                             = "rootDev2"
db_password                             = "csye6225_DevTwo"
db_publicly_accessible                  = "true"
db_skip_final_snapshot                  = "true"
db_storage_type                         = "gp2"
db_allocated_storage                    = "20"
rds_subnet_group_name                   = "rds_subnet_group_name_dev1"
# vpc_id = "vpc-0957b9218d19a6054"

s3_bucket                               = "dev.recipebyaman.me"
s3_acl                                  = "private"
s3_force_destroy                        = "true"
s3_lifecycle_id                         = "lifecycle_log"  
s3_lifecycle_enabled                    = "true"  
# s3_lifecycle_prefix                     = "log/"
s3_lifecycle_transition_days            = "30"
s3_lifecycle_transition_storage_class   = "STANDARD_IA"
s3_bucket_name                          = "MyBucketDevOne"

ami                                     = "ami-0908f85c3e592837c"
instance_type                           = "t2.micro"
disable_api_termination                 = "false"    
volume_size                             = "20"
volume_type                             = "gp2"
delete_on_termination                   = "false"
device_name                             = "/dev/sdg"
ec2_name                                = "MyEC2_DevOne"

dynamoDB_name                           = "csye6225_DynamoDBDevOne"
dynamoDB_hashKey                        = "UserId_DevOne"
dynamoDB_writeCapacity                  = "20"  
dynamoDB_readCapacity                   = "20"      
