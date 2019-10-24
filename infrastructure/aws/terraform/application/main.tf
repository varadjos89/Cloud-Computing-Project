
resource "aws_security_group" "application" {
  name              = "application"
  description       = "Security Group to host web application"
  vpc_id            = "${var.vpc_id}"

  ingress {
    from_port       = 22 
    to_port         = 22   
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = "${var.subnetCidrBlock}"
    #cidr_blocks values??
  }

  ingress {
    from_port       = 80 
    to_port         = 80   
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = "${var.subnetCidrBlock}"
  }

  ingress {
    from_port       = 443 
    to_port         = 443  
    protocol        = "${var.aws_security_group_protocol}"
    cidr_blocks     = "${var.subnetCidrBlock}"
  }

}

resource "aws_security_group" "database" {
  name              = "database"
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
  name              = "rds-subnet-group_new"
  # subnet_ids        = "${element(data.aws_subnet_ids.private.ids, 1)}"
  subnet_ids        =  ["${var.rds_subnet1}","${var.rds_subnet2}"]
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
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "${var.db_engine}"
  engine_version        = "${var.db_engine_version}"
  instance_class        = "${var.db_instance}"
  multi_az              = "${var.db_multi_az}"
  identifier            = "${var.db_identifier}"
  username              = "${var.db_username}"
  password              = "${var.db_password}"
  db_subnet_group_name  = "${aws_db_subnet_group.rds-subnet.name}"
  publicly_accessible   = "${var.db_publicly_accessible}"
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

resource "aws_instance" "ec2_instance" {
  ami                       = "${var.ami}"
  instance_type             = "${var.instance_type}"
  disable_api_termination   = "${var.disable_api_termination}"
  availability_zone         = "${var.subnetZones[2]}"

  ebs_block_device {
    device_name               = "${var.device_name}"
    volume_size               = "${var.volume_size}"
    volume_type               = "${var.volume_type}"
    delete_on_termination     = "${var.delete_on_termination}"
  }

  tags = {
    Name = "MyEC2"
  }
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