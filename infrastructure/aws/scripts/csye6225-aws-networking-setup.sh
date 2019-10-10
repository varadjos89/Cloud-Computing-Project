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
