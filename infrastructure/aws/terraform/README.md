Steps to run the Terraform configuration files

1. Run "terraform init" command to initialize a working directory containing Terraform configuration files
2. Run "terraform apply" command to apply the changes required to reach the desired state of the configuration. Enter the value of various parameters in          concole
   a) Enter cidr vpc value : 10.0.0.0/16
   b) Enter internet gateway name : MyInternetGateway (can be any name)
   c) Enter Profile : dev (for development instance) & Prod (for production instance)
   d) Enter region : us-east-1 (region for dev instance) & us-east-2 (region for prod instance)
   e) Enter route table name : MyRouteTable (can be any name)
   f) Enter subnet cidr block value : ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
   g) Enter subnet Name : MySubnet
   h) Enter VPC Name : MyVPC
   i) Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.
      Enter "yes" to approve

      We will see a message that Apply complete! Resources: 6 added, 3 chnaged, 0 destroyed
3. Run "terraform destroy" command to destroy the Terraform-managed infrastructure.       