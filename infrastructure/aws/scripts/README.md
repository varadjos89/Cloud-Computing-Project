Steps to run scripts using AWS Command Line Interface

1)Install AWS CLI with pip

2)Run $ aws --version to verify that the AWS CLI installed correctly

3)Run command $ bash csye6225-aws-networking-setup.sh

4)Enter region name, VPC name, VPC cidr, Subnet cidr as a input.

5)User should follow proper format for providing input.

6)Then system creates VPC, subnets, Internet Gateway, attach the internet gateway to the VPC, generate route table, attach all subnets to route table and create public route in it.

7)On getting any error while creating a resource system automatically breaks the execution of bash file.

