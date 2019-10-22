module "module1" {
   source = "../"

   cidrVpc = "${var.cidrVpc}"
   vpcName = "${var.vpcName}"
   subnetCidrBlock = "${var.subnetCidrBlock}"
   subnetName = "${var.subnetName}"
   internetGatewayName = "${var.internetGatewayName}"
   routeTableName = "${var.routeTableName}"
   region = "${var.region}"
   subnetCount = "${var.subnetCount}"
   subnetZones = "${var.subnetZones}"
   profile = "${var.profile}"
}