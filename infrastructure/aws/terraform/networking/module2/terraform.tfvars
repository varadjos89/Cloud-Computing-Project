vpcName = "myModule2Vpc"
region = "us-east-1"
subnetName = "myModule2Subnet"
subnetCount = "3"
internetGatewayName = "myModule2IG"
routeTableName = "myModule2RT"
cidrVpc = "10.0.0.0/16"
subnetCidrBlock = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]
subnetZones = ["us-east-1d","us-east-1e","us-east-1f"]

SGDatabase                              = "DatabaseDevTwo"
SGApplication                           = "ApplicationDevTwo"

# vpc_id                                  = "$"
aws_security_group_protocol             = "tcp"
db_name                                 = "csye6225DB"  
db_engine                               = "mysql"  
db_engine_version                       = "5.7"
db_instance                             = "db.t2.medium"
db_multi_az                             = "false"
db_identifier                           = "csye6225-dev2"
db_username                             = "rootDev2"
db_password                             = "csye6225_DevTwo"
db_publicly_accessible                  = "true"
db_skip_final_snapshot                  = "true"
db_storage_type                         = "gp2"
db_allocated_storage                    = "20"
rds_subnet_group_name                   = "rds_subnet_group_name_dev2"
# vpc_id = "vpc-0957b9218d19a6054"

s3_bucket                               = "dev.recipebyaman.me"
s3_acl                                  = "private"
s3_force_destroy                        = "true"
s3_lifecycle_id                         = "lifecycle_log"  
s3_lifecycle_enabled                    = "true"  
# s3_lifecycle_prefix                     = "log/"
s3_lifecycle_transition_days            = "30"
s3_lifecycle_transition_storage_class   = "STANDARD_IA"
s3_bucket_name                          = "MyBucketDevTwo"

ami                                     = "ami-0908f85c3e592837c"
instance_type                           = "t2.micro"
disable_api_termination                 = "false"    
volume_size                             = "20"
volume_type                             = "gp2"
delete_on_termination                   = "false"
device_name                             = "/dev/sdg"
ec2_name                                = "MyEC2_DevTwo"

dynamoDB_name                           = "csye6225_DynamoDBDevTwo"
dynamoDB_hashKey                        = "UserId_DevTwo"
dynamoDB_writeCapacity                  = "20"  
dynamoDB_readCapacity                   = "20"      
