
resource "aws_security_group" "application" {
  name              = "${var.SGApplication}"
  description       = "Security Group to host web application"
  vpc_id            = "${var.vpc_id}"

  ingress {
    from_port       = 22 
    to_port         = 22   
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
    #cidr_blocks values??
  }

  ingress {
    from_port       = 80 
    to_port         = 80   
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443 
    to_port         = 443  
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080 
    to_port         = 8080  
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80   
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 443 
    to_port         = 443  
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database" {
  name              = "${var.SGDatabase}"
  description       = "Security Group for database"
  vpc_id            = "${var.vpc_id}"
}


# data "aws_subnet_ids" "vpc" {
#   vpc_id = "${var.vpc_id}"
# }

# data "aws_subnet" "subnet1" {
#   count = "${length(data.aws_subnet_ids.vpc.ids)}"
#   id    = "${data.aws_subnet_ids.vpc.ids[count.index]}"
# }

# data "aws_subnet" "subnet2" {
#   count = "${length(data.aws_subnet_ids.vpc.ids)}"
#   id    = "${data.aws_subnet_ids.vpc.ids[count.index]}"
# }
resource "aws_db_subnet_group" "rds-subnet" {
  # count             = "${var.subnetCount}"
  name              = "${var.rds_subnet_group_name}"
  # subnet_ids        = "${element(data.aws_subnet_ids.private.ids, 1)}"
  subnet_ids        =  ["${element(tolist(data.aws_subnet_ids.subnet.ids), 0)}","${element(tolist(data.aws_subnet_ids.subnet.ids), 1)}"]
  # subnet_ids          = ["${var.rds_subnet1}","${var.rds_subnet2}"]
  #rds_subnet_id1 and rds_subnet_id2 not yet defined
}

resource "aws_security_group_rule" "database_rule" {
  from_port                     = 3306
  to_port                       = 3306
  protocol                      = "${var.aws_security_group_protocol}"
  type                          = "ingress"
  source_security_group_id      = "${aws_security_group.application.id}"
  security_group_id             = "${aws_security_group.database.id}"
  # cidr_blocks         = ["10.0.1.0/24"]
}

resource "aws_db_instance" "my_rds" {
  name                  = "${var.db_name}"
  allocated_storage     = "${var.db_allocated_storage}"
  storage_type          = "${var.db_storage_type}"
  engine                = "${var.db_engine}"
  engine_version        = "${var.db_engine_version}"
  instance_class        = "${var.db_instance}"
  multi_az              = "${var.db_multi_az}"
  identifier            = "${var.db_identifier}"
  username              = "${var.db_username}"
  password              = "${var.db_password}"
  db_subnet_group_name  = "${aws_db_subnet_group.rds-subnet.name}"
  publicly_accessible   = "${var.db_publicly_accessible}"
  vpc_security_group_ids= ["${aws_security_group.database.id}"]  
  skip_final_snapshot   = "${var.db_skip_final_snapshot}"
}

resource "aws_s3_bucket" "my_s3_bucket" {
  bucket                = "${var.s3_bucket}"
  acl                   = "${var.s3_acl}"  
  force_destroy         = "${var.s3_force_destroy}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "${var.s3_bucket_name}"
  }

  lifecycle_rule {
    id                    = "${var.s3_lifecycle_id}"
    enabled               = "${var.s3_lifecycle_enabled}"
    # prefix                = "${var.s3_lifecycle_prefix}"

    transition {
      days                = "${var.s3_lifecycle_transition_days}"
      storage_class       = "${var.s3_lifecycle_transition_storage_class}"
    }
  }
}

data "aws_availability_zones" "available" {
    state = "available" 
}

data "aws_subnet_ids" "subnet" {
    vpc_id = "${var.vpc_id}"
}


/*resource "aws_instance" "ec2_instance" {
  ami                       = "${var.ami}"
  instance_type             = "${var.instance_type}"
  disable_api_termination   = "${var.disable_api_termination}"
  availability_zone         = "${data.aws_availability_zones.available.names[1]}"
  key_name                  = "${var.key_name}"

  ebs_block_device {
    device_name               = "${var.device_name}"
    volume_size               = "${var.volume_size}"
    volume_type               = "${var.volume_type}"
    delete_on_termination     = "${var.delete_on_termination}"
  }

  tags = {
    Name = "${var.ec2_name}"
  }

  vpc_security_group_ids      = ["${aws_security_group.application.id}"]
  associate_public_ip_address = true
  source_dest_check           = false
  subnet_id                   = "${element(tolist(data.aws_subnet_ids.subnet.ids), 1)}"
  depends_on                  = ["aws_db_instance.my_rds"]
}*/

resource "aws_dynamodb_table" "dynamoDB_Table" {
  name                        = "${var.dynamoDB_name}"
  hash_key                    = "${var.dynamoDB_hashKey}"
  write_capacity              = "${var.dynamoDB_writeCapacity}"
  read_capacity               = "${var.dynamoDB_readCapacity}"

  attribute {
    name = "${var.dynamoDB_hashKey}"
    type = "S"
  }
}

resource "aws_iam_policy" "policy1" {
  name        = "CircleCI-Code-Deploy"
  description = "Code Deploy Policy for user circleci"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.aws_region}:${var.aws_accountid}:application:${var.aws_application_name}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.aws_region}:${var.aws_accountid}:deploymentgroup:${var.aws_application_group}" 
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.aws_region}:${var.aws_accountid}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:${var.aws_region}:${var.aws_accountid}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:${var.aws_region}:${var.aws_accountid}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}


resource "aws_iam_policy" "policy2" {
  name        = "CircleCI-Upload-To-S3"
  description = "s3 upload Policy for user circleci"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name_application}/*"
            ]
        }
    ]
}

EOF
}

resource "aws_iam_policy" "policy3" {
  name        = "circleci-ec2-ami"
  description = "EC2 access for user circleci"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action" : [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource" : "*"
  }]
}
EOF
}

resource "aws_iam_policy_attachment" "circleci-attach1" {
  name       = "circleci-attachment-codedeploy"
  users      = ["${var.aws_circleci_user_name}"]
  #roles      = ["${aws_iam_role.role.name}"]
  #groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.policy1.arn}"
  depends_on = [aws_iam_policy.policy1]
}

resource "aws_iam_policy_attachment" "circleci-attach2" {
  name       = "circleci-attachment-uploadtos3"
  users      = ["${var.aws_circleci_user_name}"]
  #roles      = ["${aws_iam_role.role.name}"]
  #groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.policy2.arn}"
  depends_on = [aws_iam_policy.policy2]
}

resource "aws_iam_policy_attachment" "circleci-attach3" {
  name       = "circleci-attachment-ec2-ami"
  users      = ["${var.aws_circleci_user_name}"]
  #roles      = ["${aws_iam_role.role.name}"]
  #groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.policy3.arn}"
  depends_on = [aws_iam_policy.policy3]
}

resource "aws_iam_policy" "policy4" {
  name        = "CodeDeploy-EC2-S3"
  description = "EC2 s3 access policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name_application}",
                "arn:aws:s3:::*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "role1" {
  name = "CodeDeployEC2ServiceRole"
  description = "Allows EC2 instances to call AWS services on your behalf"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_iam_role" "role2" {
  name = "CodeDeployServiceRole"
  description = "Allows CodeDeploy to call AWS services such as Auto Scaling on your behalf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy5" {
  name        = "Cloudwatchagent-server-policy"
  description = "Permissions required to use AmazonCloudWatchAgent on servers"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:::parameter/AmazonCloudWatch-*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role1-attach5" {
  role       = "${aws_iam_role.role1.name}"
  policy_arn = "${aws_iam_policy.policy5.arn}"
}


resource "aws_codedeploy_app" "app" {
  name = "csye6225-webapp"
}
resource "aws_codedeploy_deployment_group" "example" {
    depends_on = [aws_codedeploy_app.app]

  app_name="csye6225-webapp"
  deployment_group_name="csye6225-webapp-deployment"
  service_role_arn       = "${aws_iam_role.role2.arn}"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
ec2_tag_set {
  ec2_tag_filter {
    key   = "a"
    type  = "KEY_AND_VALUE"
    value = "b"
  }
}

}


resource "aws_iam_instance_profile" "role1_profile" {
  name = "CodeDeployEC2ServiceRole"
  role = "${aws_iam_role.role1.name}"
}

resource "aws_iam_role_policy_attachment" "role1-attach" {
  role       = "${aws_iam_role.role1.name}"
  policy_arn = "${aws_iam_policy.policy4.arn}"
}




resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = "${aws_iam_role.role2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_s3_bucket" "code_deploy" {
  bucket        = "${var.s3_bucket_name_application}"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  tags = {
    Name        = "codedeploy"
  }

  lifecycle_rule {
    enabled = "true"
    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }
  }

}

resource "aws_instance" "web-1" {
  ami               = "${var.ami}"
  instance_type     = "t2.micro"
  key_name          = "${var.key_name}"
  #user_data         = "${file("install_codedeploy_agent.sh")}"
  #echo host=${var.end_point} >> .env
  user_data         = "${templatefile("${path.module}/user_data.sh",
                                {
                                  aws_db_endpoint = "csye6225-dev.cfwlaur60sw1.us-east-1.rds.amazonaws.com",
                                  bucketName= var.s3_bucket,
                                  dbname= var.db_name,
                                  dbUsername= var.db_username,
                                  dbPassword= var.db_password
                                })}"
  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = "20"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }
  #iam_instance_profile="${aws_iam_instance_profile.role1_profile.name}"


  tags = {
    a = "b"
  }
  vpc_security_group_ids = ["${aws_security_group.application.id}"]

  associate_public_ip_address = true
  source_dest_check           = false
  #subnet_id                   = "${element(tolist(data.aws_subnet_ids.subnet.ids), 0)}"
  subnet_id                   = "subnet-033bf74e"
  depends_on=["aws_db_instance.my_rds"]
}

