#!/bin/sh
#shell script to delete AWS stack
stackName=$1

aws cloudformation delete-stack --stack-name $stackName --region $2

if [ $? -eq 0 ]; then
  echo "Delete in progress..."
  aws cloudformation wait stack-delete-complete --stack-name $stackName --region $2
  echo "Stack deleted successfully"
else
  echo "Failure while deleting stack"
fi