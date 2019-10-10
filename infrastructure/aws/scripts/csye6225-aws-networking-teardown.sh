#Getting vpcId
        echo "--Enter the VPC name to delete"


        read vpcName


        vpcid=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${vpcName}" --query 'Vpcs[*].{id:VpcId}' | jq -r '.[] | .id') &&
        echo The vpc id is "$vpcid"
        VPC_CREATE_STATUS=$?
        echo  "VPC : "
        echo $VPC_CREATE_STATUS

      if [ -z $vpcid ]; then
                echo " Please pass the correct vpc name"
                exit 1
        fi

        #Deleting  Subnet
        echo "Deleting Subnets"
        subnet=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpcid}")

        subnetid1=$(echo -e "$subnet" | jq '.Subnets[0].SubnetId' | tr -d '"')
        subnetid2=$(echo -e "$subnet" | jq '.Subnets[1].SubnetId' | tr -d '"')
        subnetid3=$(echo -e "$subnet" | jq '.Subnets[2].SubnetId' | tr -d '"')
        aws ec2 delete-subnet --subnet-id $subnetid1

        aws ec2 delete-subnet --subnet-id $subnetid2
        aws ec2 delete-subnet --subnet-id $subnetid3

    #Getting route-id
    {

        Rname=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpcid" --query 'RouteTables[*].{id:Tags}' | jq -r '.[] | .id[].Value') &&
        echo Route table name is "$Rname"
    } && {
        Rid=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=$Rname" --query 'RouteTables[*].{id:RouteTableId}' | jq -r '.[] | .id') &&
        
        echo Route table id is "$Rid"
    } || {
        echo "Route table not found. Exiting Script."
        exit 1
    }


    #Deleting route
    {
            aws ec2 delete-route --route-table-id $Rid --destination-cidr-block 0.0.0.0/0 &&
            echo "*Deleted Route*"
    } ||  {
            echo "Unable to delete Route. Exiting script."
            exit 1
    }

    #Deleting route-table
    {
            aws ec2 delete-route-table --route-table-id $Rid &&
            echo "*Deleted Route-Table*"
    } || {
            echo "Unable to delete the Route table. Exiting Script."
            exit 1
    }