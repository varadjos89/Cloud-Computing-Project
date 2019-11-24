

resource "aws_s3_bucket" "Lambda_func" {
  bucket        = "${var.s3_bucket_name_lambda}"
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
    noncurrent_version_expiration {
      days = 60
    }
    expiration {
      days = 60
    }
  }

}

resource "aws_lambda_function" "func" {
  function_name = "csye6225_fall2019"
  filename      = "./webapp-1.0-SNAPSHOT.jar"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "com.csye6225.EventLog::handleRequest"
  runtime       = "java8"
  timeout       = 30
  memory_size   = 256
  environment {
    variables = {
      domain_name = "${var.domain_name}"
      ttl = "${var.ttl}"
    }
}
}


resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.func.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.default.arn}"
}
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.func.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:eu-west-1:111122223333:rule/RunDaily"
}
resource "aws_sns_topic" "default" {
  name = "EmailTopic"
  display_name="EmailTopic"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.default.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.func.arn}"
}



resource "aws_iam_role" "lambda" {
  name = "myRecipe-role-1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

## Security Group for ALB
resource "aws_security_group" "lb_sg" {
  name = "aws_lb_sg"
  vpc_id = "${var.vpc_id}"
  description = "Allow ALB inbound traffic"
  egress {  
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "LBServerSG"
  }
}


resource "aws_security_group" "application" {
  name              = "${var.SGApplication}"
  description       = "Security Group to host web application"
  vpc_id            = "${var.vpc_id}"

  ingress {
    from_port       = 22 
    to_port         = 22   
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  /*ingress {
    from_port       = 80 
    to_port         = 80   
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }*/

  /*ingress {
    from_port       = 443 
    to_port         = 443  
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }*/

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_sg.id}"]
   }

  /*ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = ["0.0.0.0/0"]
  }*/

  /*egress {
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
  }*/

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

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_subnet_group" "rds-subnet" {
  name              = "${var.rds_subnet_group_name}"
  subnet_ids        =  ["${element(tolist(data.aws_subnet_ids.subnet.ids), 0)}","${element(tolist(data.aws_subnet_ids.subnet.ids), 1)}"]

}

resource "aws_security_group_rule" "database_rule" {
  from_port                     = 3306
  to_port                       = 3306
  protocol                      = "${var.aws_security_group_protocol}"
  type                          = "ingress"
  source_security_group_id      = "${aws_security_group.application.id}"
  security_group_id             = "${aws_security_group.database.id}"
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
    Name        = "codedeploy"
  }

  lifecycle_rule {
    id                    = "${var.s3_lifecycle_id}"
    enabled               = "${var.s3_lifecycle_enabled}"

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
        "arn:aws:codedeploy:${var.aws_region}:${var.aws_accountid}:deploymentgroup:${var.aws_application_name}/${var.aws_application_group}" 
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

resource "aws_iam_policy" "policy8" {
  name        = "log-policy"
  description = "The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:*",
                "logs:*",
                "sns:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "events.amazonaws.com"
                }
            }
        }
    ]
}
EOF
}
resource "aws_iam_policy" "policy9" {
  name        = "DynamoDB-policy"
  description = "The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:*",
                "dax:*",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:DescribeScalableTargets",
                "application-autoscaling:DescribeScalingActivities",
                "application-autoscaling:DescribeScalingPolicies",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:RegisterScalableTarget",
                "cloudwatch:DeleteAlarms",
                "cloudwatch:DescribeAlarmHistory",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmsForMetric",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:PutMetricAlarm",
                "datapipeline:ActivatePipeline",
                "datapipeline:CreatePipeline",
                "datapipeline:DeletePipeline",
                "datapipeline:DescribeObjects",
                "datapipeline:DescribePipelines",
                "datapipeline:GetPipelineDefinition",
                "datapipeline:ListPipelines",
                "datapipeline:PutPipelineDefinition",
                "datapipeline:QueryObjects",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "iam:GetRole",
                "iam:ListRoles",
                "sns:CreateTopic",
                "sns:DeleteTopic",
                "sns:ListSubscriptions",
                "sns:ListSubscriptionsByTopic",
                "sns:ListTopics",
                "sns:Subscribe",
                "sns:Unsubscribe",
                "sns:SetTopicAttributes",
                "lambda:CreateFunction",
                "lambda:ListFunctions",
                "lambda:ListEventSourceMappings",
                "lambda:CreateEventSourceMapping",
                "lambda:DeleteEventSourceMapping",
                "lambda:GetFunctionConfiguration",
                "lambda:DeleteFunction",
                "resource-groups:ListGroups",
                "resource-groups:ListGroupResources",
                "resource-groups:GetGroup",
                "resource-groups:GetGroupQuery",
                "resource-groups:DeleteGroup",
                "resource-groups:CreateGroup",
                "tag:GetResources"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": [
                        "application-autoscaling.amazonaws.com",
                        "dax.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.dynamodb.amazonaws.com",
                        "dax.amazonaws.com",
                        "dynamodb.application-autoscaling.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "circleci-attach1" {
  name       = "circleci-attachment-codedeploy"
  users      = ["${var.aws_circleci_user_name}"]
  policy_arn = "${aws_iam_policy.policy1.arn}"
  depends_on = [aws_iam_policy.policy1]
}

resource "aws_iam_policy_attachment" "circleci-attach2" {
  name       = "circleci-attachment-uploadtos3"
  users      = ["${var.aws_circleci_user_name}"]
  policy_arn = "${aws_iam_policy.policy2.arn}"
  depends_on = [aws_iam_policy.policy2]
}

resource "aws_iam_policy_attachment" "circleci-attach3" {
  name       = "circleci-attachment-ec2-ami"
  users      = ["${var.aws_circleci_user_name}"]
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
                "s3:List*",
                "s3:Put*",
                "s3:Delete*"
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

resource "aws_iam_policy" "policy6" {
  name        = "SSM-policy"
  description = "The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
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

resource "aws_iam_policy" "policy7" {
  name        = "SNS-policy"
  description = "The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sns:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "policy10" {
  name        = "SES-policy"
  description = "The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "role1-attach4" {
  role       = "${aws_iam_role.role1.name}"
  policy_arn = "${aws_iam_policy.policy4.arn}"
}

resource "aws_iam_role_policy_attachment" "role1-attach5" {
  role       = "${aws_iam_role.role1.name}"
  policy_arn = "${aws_iam_policy.policy5.arn}"
}

resource "aws_iam_role_policy_attachment" "role1-attach6" {
  role       = "${aws_iam_role.role1.name}"
  policy_arn = "${aws_iam_policy.policy6.arn}"
}
resource "aws_iam_role_policy_attachment" "role1-attach7" {
  role       = "${aws_iam_role.role1.name}"
  policy_arn = "${aws_iam_policy.policy7.arn}"
}
resource "aws_iam_role_policy_attachment" "role1-attach8" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.policy8.arn}"
}
resource "aws_iam_role_policy_attachment" "role1-attach9" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.policy9.arn}"
}
resource "aws_iam_role_policy_attachment" "role1-attach10" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.policy10.arn}"
}
resource "aws_iam_instance_profile" "role1_profile" {
  name = "CodeDeployEC2ServiceRole"
  role = "${aws_iam_role.role1.name}"
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

resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = "${aws_iam_role.role2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}


# auto scaling policy
resource "aws_autoscaling_policy" "as_policy1" {
  name                   = "WebServerScaleUpPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.as_group.name}"
}

resource "aws_autoscaling_policy" "as_policy2" {
  name                   = "WebServerScaleDownPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.as_group.name}"
}

resource "aws_cloudwatch_metric_alarm" "as_policy3" {
  alarm_name          = "CPUAlarmHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.as_group.name}"
  }

  alarm_description = "Scale-up if CPU > 60% for 1 minutes"
  alarm_actions     = ["${aws_autoscaling_policy.as_policy1.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "as_policy4" {
  alarm_name          = "CPUAlarmLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.as_group.name}"
  }

  alarm_description = "Scale-down if CPU < 50% for 2 minutes"
  alarm_actions     = ["${aws_autoscaling_policy.as_policy2.arn}"]
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

 alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${aws_lb_listener.ssl.arn}"]
      }

      target_group {
        name = "${aws_lb_target_group.front_end.name}"
      }

    }
  }
    autoscaling_groups = ["${aws_autoscaling_group.as_group.name}"]

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

# auto scaling launch config
resource "aws_launch_configuration" "launch_config" {
  name                          = "as-lc-handler"
  image_id                      = "${var.ami}"
  instance_type                 = "t2.micro"
  key_name                      = "${var.key_name}"
  associate_public_ip_address   = true
  user_data                     = <<-EOF
                                #!/bin/bash -ex
                                exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
                                sudo service codedeploy-agent status
                                sudo service codedeploy-agent start
                                sudo service codedeploy-agent status
  EOF

  iam_instance_profile          ="${aws_iam_instance_profile.role1_profile.name}"
  security_groups               =["${aws_security_group.application.id}"]
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }
}


# Creating AutoScaling Group
resource "aws_autoscaling_group" "as_group" {
  name                 = "WebServerGroup"
  launch_configuration = "${aws_launch_configuration.launch_config.id}"
  min_size             = 3
  max_size             = 10
  default_cooldown     = 60
  force_delete         = true
  target_group_arns    = ["${aws_lb_target_group.front_end.arn}"]
  vpc_zone_identifier = ["${element(tolist(data.aws_subnet_ids.subnet.ids), 0)}", "${element(tolist(data.aws_subnet_ids.subnet.ids), 1)}","${element(tolist(data.aws_subnet_ids.subnet.ids), 2)}"]
  tag {
    key = "a"
    value = "b"
    propagate_at_launch = true
  }
}

data "aws_route53_zone" "selected" {
  name    = "${var.domain_name}"
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.selected.id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.my_lb.dns_name}"
    zone_id                = "${aws_lb.my_lb.zone_id}"
    evaluate_target_health = false
  }
}

data "aws_acm_certificate" "example" {
  domain   = "${var.domain_name}"
  statuses = ["ISSUED"]
}

resource "aws_lb" "my_lb" {
  name               = "ApplicationLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    ="ipv4"
  security_groups    = ["${aws_security_group.lb_sg.id}"]
  subnets = ["${element(tolist(data.aws_subnet_ids.subnet.ids), 0)}", "${element(tolist(data.aws_subnet_ids.subnet.ids), 1)}","${element(tolist(data.aws_subnet_ids.subnet.ids), 2)}"]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "ssl" {
  load_balancer_arn = "${aws_lb.my_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.example.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.front_end.arn}"
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "awsLbTargetGroup"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check {
    interval=30
    timeout=5
    healthy_threshold=3
    unhealthy_threshold=5
    path="/healthCheck"
  }

}


# AWS WAF
resource "aws_cloudformation_stack" "waf" {
  name = "waf-example"
  depends_on = [aws_s3_bucket.Lambda_func,
                aws_s3_bucket.my_s3_bucket,
                aws_s3_bucket.code_deploy]
  parameters = {
    ALBArn = "${aws_lb.my_lb.arn}"
  }

  template_body = <<STACK
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "Cloud Formation Template - CSYE6225 - Creating WAF Rules",
    "Parameters": {
        "IPtoBlock1": {
            "Description": "IPAddress to be blocked",
            "Default": "155.33.133.6/32",
            "Type": "String"
        },    
        "ALBArn": {
            "Description": "IPAddress to be blocked",
            "Type": "String"
        },
        "IPtoBlock2": {
            "Description": "IPAddress to be blocked",
            "Default": "192.0.7.0/24",
            "Type": "String"
        }
    },
    "Resources": {
        "wafrSQLiSet": {
            "Type": "AWS::WAFRegional::SqlInjectionMatchSet",
            "Properties": {
                "Name": "wafrSQLiSet",
                "SqlInjectionMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "cookie"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "cookie"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "Authorization"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "Authorization"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    }
                ]
            }
        },
        "wafrSQLiRule": {
            "Type": "AWS::WAFRegional::Rule",
            "DependsOn": [
                "wafrSQLiSet"
            ],
            "Properties": {
                "MetricName": "wafrSQLiRule",
                "Name": "wafr-SQLiRule",
                "Predicates": [
                    {
                        "Type": "SqlInjectionMatch",
                        "Negated": false,
                        "DataId": {
                            "Ref": "wafrSQLiSet"
                        }
                    }
                ]
            }
        },
        "MyIPSetWhiteList": {
            "Type": "AWS::WAFRegional::IPSet",
            "Properties": {
                "Name": "WhiteList IP Address Set",
                "IPSetDescriptors": [
                    {
                        "Type": "IPV4",
                        "Value": "155.33.135.11/32"
                    },
                    {
                        "Type": "IPV4",
                        "Value": "192.0.7.0/24"
                    }
                ]
            }
        },
        "MyIPSetWhiteListRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "Name": "WhiteList IP Address Rule",
                "MetricName": "MyIPSetWhiteListRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "MyIPSetWhiteList"
                        },
                        "Negated": false,
                        "Type": "IPMatch"
                    }
                ]
            }
        },
        "myIPSetBlacklist": {
            "Type": "AWS::WAFRegional::IPSet",
            "Properties": {
                "Name": "myIPSetBlacklist",
                "IPSetDescriptors": [
                    {
                        "Type": "IPV4",
                        "Value": {
                            "Ref": "IPtoBlock1"
                        }
                    },
                    {
                        "Type": "IPV4",
                        "Value": {
                            "Ref": "IPtoBlock2"
                        }
                    }
                ]
            }
        },
        "myIPSetBlacklistRule": {
            "Type": "AWS::WAFRegional::Rule",
            "DependsOn": [
                "myIPSetBlacklist"
            ],
            "Properties": {
                "Name": "Blacklist IP Address Rule",
                "MetricName": "myIPSetBlacklistRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "myIPSetBlacklist"
                        },
                        "Negated": false,
                        "Type": "IPMatch"
                    }
                ]
            }
        },
        "MyScanProbesSet": {
            "Type": "AWS::WAFRegional::IPSet",
            "Properties": {
                "Name": "MyScanProbesSet"
            }
        },
        "MyScansProbesRule": {
            "Type": "AWS::WAFRegional::Rule",
            "DependsOn": "MyScanProbesSet",
            "Properties": {
                "Name": "MyScansProbesRule",
                "MetricName": "SecurityAutomationsScansProbesRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "MyScanProbesSet"
                        },
                        "Negated": false,
                        "Type": "IPMatch"
                    }
                ]
            }
        },
        "DetectXSS": {
            "Type": "AWS::WAFRegional::XssMatchSet",
            "Properties": {
                "Name": "XssMatchSet",
                "XssMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "URL_DECODE"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "HTML_ENTITY_DECODE"
                    }
                ]
            }
        },
        "XSSRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "Name": "XSSRule",
                "MetricName": "XSSRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "DetectXSS"
                        },
                        "Negated": false,
                        "Type": "XssMatch"
                    }
                ]
            }
        },
        "sizeRestrict": {
            "Type": "AWS::WAFRegional::SizeConstraintSet",
            "Properties": {
                "Name": "sizeRestrict",
                "SizeConstraints": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": "512"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": "1024"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "BODY"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": "204800"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "cookie"
                        },
                        "TextTransformation": "NONE",
                        "ComparisonOperator": "GT",
                        "Size": "4096"
                    }
                ]
            }
        },
        "reqSizeRule": {
            "Type": "AWS::WAFRegional::Rule",
            "DependsOn": [
                "sizeRestrict"
            ],
            "Properties": {
                "MetricName": "reqSizeRule",
                "Name": "reqSizeRule",
                "Predicates": [
                    {
                        "Type": "SizeConstraint",
                        "Negated": false,
                        "DataId": {
                            "Ref": "sizeRestrict"
                        }
                    }
                ]
            }
        },
        "PathStringSetReferers": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": "Path String Referers Set",
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": "../",
                        "TextTransformation": "URL_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": "../",
                        "TextTransformation": "HTML_ENTITY_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TargetString": "../",
                        "TextTransformation": "URL_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TargetString": "../",
                        "TextTransformation": "HTML_ENTITY_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": "://",
                        "TextTransformation": "URL_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": "://",
                        "TextTransformation": "HTML_ENTITY_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TargetString": "://",
                        "TextTransformation": "URL_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "QUERY_STRING"
                        },
                        "TargetString": "://",
                        "TextTransformation": "HTML_ENTITY_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    }
                ]
            }
        },
        "PathStringSetReferersRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "Name": "PathStringSetReferersRule",
                "MetricName": "PathStringSetReferersRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "PathStringSetReferers"
                        },
                        "Negated": false,
                        "Type": "ByteMatch"
                    }
                ]
            }
        },
        "BadReferers": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": "Bad Referers",
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "cookie"
                        },
                        "TargetString": "badrefer1",
                        "TextTransformation": "URL_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "HEADER",
                            "Data": "authorization"
                        },
                        "TargetString": "QGdtYWlsLmNvbQ==",
                        "TextTransformation": "URL_DECODE",
                        "PositionalConstraint": "CONTAINS"
                    }
                ]
            }
        },
        "BadReferersRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "Name": "BadReferersRule",
                "MetricName": "BadReferersRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "BadReferers"
                        },
                        "Negated": false,
                        "Type": "ByteMatch"
                    }
                ]
            }
        },
        "ServerSideIncludesSet": {
            "Type": "AWS::WAFRegional::ByteMatchSet",
            "Properties": {
                "Name": "Server Side Includes Set",
                "ByteMatchTuples": [
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": "/includes",
                        "TextTransformation": "URL_DECODE",
                        "PositionalConstraint": "STARTS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".cfg",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".conf",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".config",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".ini",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".log",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".bak",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".bakup",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    },
                    {
                        "FieldToMatch": {
                            "Type": "URI"
                        },
                        "TargetString": ".txt",
                        "TextTransformation": "LOWERCASE",
                        "PositionalConstraint": "ENDS_WITH"
                    }
                ]
            }
        },
        "ServerSideIncludesRule": {
            "Type": "AWS::WAFRegional::Rule",
            "Properties": {
                "Name": "ServerSideIncludesRule",
                "MetricName": "ServerSideIncludesRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "ServerSideIncludesSet"
                        },
                        "Negated": false,
                        "Type": "ByteMatch"
                    }
                ]
            }
        },
        "WAFAutoBlockSet": {
            "Type": "AWS::WAFRegional::IPSet",
            "Properties": {
                "Name": "Auto Block Set"
            }
        },
        "MyAutoBlockRule": {
            "Type": "AWS::WAFRegional::Rule",
            "DependsOn": "WAFAutoBlockSet",
            "Properties": {
                "Name": "Auto Block Rule",
                "MetricName": "AutoBlockRule",
                "Predicates": [
                    {
                        "DataId": {
                            "Ref": "WAFAutoBlockSet"
                        },
                        "Negated": false,
                        "Type": "IPMatch"
                    }
                ]
            }
        },
        "MyWebACL": {
            "Type": "AWS::WAFRegional::WebACL",
            "Properties": {
                "Name": "MyWebACL",
                "DefaultAction": {
                    "Type": "ALLOW"
                },
                "MetricName": "MyWebACL",
                "Rules": [
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 1,
                        "RuleId": {
                            "Ref": "reqSizeRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "ALLOW"
                        },
                        "Priority": 2,
                        "RuleId": {
                            "Ref": "MyIPSetWhiteListRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 3,
                        "RuleId": {
                            "Ref": "myIPSetBlacklistRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 4,
                        "RuleId": {
                            "Ref": "MyAutoBlockRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 5,
                        "RuleId": {
                            "Ref": "wafrSQLiRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 6,
                        "RuleId": {
                            "Ref": "BadReferersRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 7,
                        "RuleId": {
                            "Ref": "PathStringSetReferersRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 8,
                        "RuleId": {
                            "Ref": "ServerSideIncludesRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 9,
                        "RuleId": {
                            "Ref": "XSSRule"
                        }
                    },
                    {
                        "Action": {
                            "Type": "BLOCK"
                        },
                        "Priority": 10,
                        "RuleId": {
                            "Ref": "MyScansProbesRule"
                        }
                    }
                ]
            }
        },
        "MyWebACLAssociation": {
            "Type": "AWS::WAFRegional::WebACLAssociation",
            "DependsOn": [
                "MyWebACL"
            ],
            "Properties": {
                "ResourceArn": {
                            "Ref": "ALBArn"
                },
                "WebACLId": {
                    "Ref": "MyWebACL"
                }
            }
        }
    }
}

STACK
}