#!/bin/bash

echo "Enter region name"
read AWS_REGION

while ! echo $AWS_REGION | grep -qP '^us-[a-z]*-[0-9]{1}'
do
  echo "Enter region name"
  read AWS_REGION
done


echo "Enter vpc name"
read VPC_NAME

while ! echo $VPC_NAME | grep -qP '[a-zA-Z]'
do
  echo "Enter vpc name"
  read VPC_NAME
done


echo "Enter vpc cidr"
read VPC_CIDR

while ! echo $VPC_CIDR | grep -qP '^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$'
do
  echo "Enter vpc cidr"
  read VPC_CIDR
done


echo "Enter cidr for 1st subnet"
read SUBNET_PUBLIC_CIDR

while ! echo $SUBNET_PUBLIC_CIDR | grep -qP '^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$'
do
  echo "Enter cidr for 1st subnet"
  read SUBNET_PUBLIC_CIDR
done


echo "Enter cidr for 2nd subnet"
read SUBNET_PUBLIC_CIDR2

while ! echo $SUBNET_PUBLIC_CIDR2 | grep -qP '^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$'
do
  echo "Enter cidr for 2nd subnet"
  read SUBNET_PUBLIC_CIDR2
done


echo "Enter cidr for 3rd subnet"
read SUBNET_PUBLIC_CIDR3

while ! echo $SUBNET_PUBLIC_CIDR3 | grep -qP '^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$'
do
  echo "Enter cidr for 3rd subnet"
  read SUBNET_PUBLIC_CIDR3
done



SUBNET_PUBLIC_AZ="us-east-1a"
SUBNET_PUBLIC_AZ2="us-east-1b"
SUBNET_PUBLIC_AZ3="us-east-1c"


echo "Creating VPC in preferred region..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.{VpcId:VpcId}' \
  --output text \
  --region $AWS_REGION)

if echo $VPC_ID | grep -qP 'vpc-[0-9a-f]{17}'
   then echo "VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."
   else echo "VPC creation failed" exit 1
fi


# Add Name tag to VPC
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags "Key=Name,Value=$VPC_NAME" \
  --region $AWS_REGION



# Create Public Subnet
echo "Creating Public Subnet..."
SUBNET_PUBLIC_ID1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC_CIDR \
  --availability-zone $SUBNET_PUBLIC_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)


if echo $SUBNET_PUBLIC_ID1 | grep -qP 'subnet-[0-9a-f]{17}'
   then echo "  Subnet ID '$SUBNET_PUBLIC_ID1' CREATED in '$SUBNET_PUBLIC_AZ'" \
  "Availability Zone."
   else echo "1st Subnet creation failed" exit 1
fi


# Create Public Subnet
echo "Creating Public Subnet..."
SUBNET_PUBLIC_ID2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC_CIDR2 \
  --availability-zone $SUBNET_PUBLIC_AZ2 \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)


if echo $SUBNET_PUBLIC_ID2 | grep -qP 'subnet-[0-9a-f]{17}'
   then echo "  Subnet ID '$SUBNET_PUBLIC_ID2' CREATED in '$SUBNET_PUBLIC_AZ2'" \
  "Availability Zone."
   else echo "2nd Subnet creation failed" exit 1
fi


# Create Public Subnet
echo "Creating Public Subnet..."
SUBNET_PUBLIC_ID3=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC_CIDR3 \
  --availability-zone $SUBNET_PUBLIC_AZ3 \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)


if echo $SUBNET_PUBLIC_ID3 | grep -qP 'subnet-[0-9a-f]{17}'
   then echo "  Subnet ID '$SUBNET_PUBLIC_ID3' CREATED in '$SUBNET_PUBLIC_AZ3'" \
  "Availability Zone."
   else echo "3rd Subnet creation failed" exit 1
fi


# Create Internet gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
  --output text \
  --region $AWS_REGION)


if echo $IGW_ID | grep -qP 'igw-[0-9a-f]{17}'
   then echo "  Internet Gateway ID '$IGW_ID' CREATED."
   else echo "Internet Gateway creation failed" exit 1
fi

# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."


# Create Route Table
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.{RouteTableId:RouteTableId}' \
  --output text \
  --region $AWS_REGION)


if echo $ROUTE_TABLE_ID | grep -qP 'rtb-[0-9a-f]{17}'
   then echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED."
   else echo "Route table creation failed" exit 1
fi


aws ec2 create-tags --resources $ROUTE_TABLE_ID --tags Key=Name,Value=hey


# Attach subnet to your Route Table
aws ec2 associate-route-table  --subnet-id $SUBNET_PUBLIC_ID1 --route-table-id $ROUTE_TABLE_ID

aws ec2 associate-route-table  --subnet-id $SUBNET_PUBLIC_ID2 --route-table-id $ROUTE_TABLE_ID

aws ec2 associate-route-table  --subnet-id $SUBNET_PUBLIC_ID3 --route-table-id $ROUTE_TABLE_ID


# Create route to Internet Gateway
RESULT=$(aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $AWS_REGION)
echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
  "Route Table ID '$ROUTE_TABLE_ID'."