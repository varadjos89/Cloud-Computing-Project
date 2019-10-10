STACK INFORMATION:
1) Virtual Private Cloud
2) 3 Subnets in different availability zones
3) Internet Gateway which is attached to VPC
4) Public Route Table. All subnets are attached to this table
5) Created a public route table with destination CIDR block 0.0.0.0/0 and internet Gateway as target

PARAMETERS REQUIRED TO CREATE STACK:
1) Stack name
2) AWS Region
3) VPC CIDR block
4) Subnet CIDR block
5) VPC name

COMMAND TO CREATE THE STACK:

./csye6225-aws-cf-create-stack.sh stack-Name Region VPC-CIDR-block Subnet-CIDR-block VPC-Name

Example:
./csye6225-aws-cf-create-stack.sh FinalStack us-east-1 10.0.0.0/16 10.0.0.0/24 10.0.1.0/24 10.0.2.0/24 VPCFinal

COMMAND TO DELETE THE STACK:

./csye6225-aws-cf-terminate-stack.sh Stack-Name Region

Example:
./csye6225-aws-cf-terminate-stack.sh FinalStack us-east-1