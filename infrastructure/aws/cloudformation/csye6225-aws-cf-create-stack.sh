#!/bin/sh

stackName=$1
Userregion=$2
UservpcCIDR=$3
Usersubnet1CIDR=$4
Usersubnet2CIDR=$5
Usersubnet3CIDR=$6
UservpcName=$7
    

aws cloudformation create-stack --stack-name $stackName --template-body file://csye6225-cf-networking.json --region $Userregion --parameters  
ParameterKey="vpcCIDR",ParameterValue=$UservpcCIDR 
ParameterKey="subnet1CIDR",ParameterValue=$Usersubnet1CIDR 
ParameterKey="subnet2CIDR",ParameterValue=$Usersubnet2CIDR 
ParameterKey="subnet3CIDR",ParameterValue=$Usersubnet3CIDR 
ParameterKey="VPCName",ParameterValue=$UservpcName

if [ $? -eq 0 ]; then
    echo "Creating Stack..."
    aws cloudformation wait stack-create-complete --stack-name $stackName --region $Userregion
    echo "Stack created successfully"
else
    echo "Failed to create the stack"
fi    
