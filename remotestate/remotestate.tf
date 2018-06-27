# VARIABLES

# you must pass this on the command line
variable "user_home" {}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "dev_state_bucket" {
  default = "aweg-state"
}

variable "dev_state_dynamo_table" {
  default = "aweg-tfstatelock"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-2"
}




data "template_file" "dev_state_bucket_policy" {
  template = "${file("templates/bucket_policy.tpl")}"

  ## todo: if we need more users, we can add a read-only access policy here,
  ## and a user elsewhere in this file.
  vars {
     admin_user_arn = "${aws_iam_user.admin_user.arn}"
     s3_bucket = "${var.dev_state_bucket}"
  }
}

## This data can be used for many "admin" type users
data "template_file" "admin_user_policy" {
  template = "${file("templates/user_policy.tpl")}"

  vars {
    s3_rw_bucket = "${var.dev_state_bucket}"
    dynamodb_table_arn = "${aws_dynamodb_table.terraform_statelock.arn}"
  }
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.dev_state_dynamo_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "bkt" {
  bucket = "${var.dev_state_bucket}"
  acl = "private"
  force_destroy = true
  
  versioning {
    enabled = true
  }

  policy = "${data.template_file.dev_state_bucket_policy.rendered}"
}

resource "aws_iam_user" "admin_user" {
  name = "admin"
}

resource "aws_iam_access_key" "admin_key" {
  user = "${aws_iam_user.admin_user.name}"
}

resource "aws_iam_user_policy" "admin_rw" {
  name = "admin"
  user = "${aws_iam_user.admin_user.name}"
  policy = "${data.template_file.admin_user_policy.rendered}"
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin_attach" {
  group      = "${aws_iam_group.ec2admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_membership" "add_ec2admin" {
  name = "add_ec2admin"

  users = [
    "${aws_iam_user.admin_user.name}",
  ]

  group = "${aws_iam_group.ec2admin.name}"
}

## Render created users to ~/.aws/credentials
resource "local_file" "aws_keys" {
  content = <<EOF
[default]
aws_access_key_id = ${var.aws_access_key}
aws_secret_access_key = ${var.aws_secret_key}

[admin]
aws_access_key_id = ${aws_iam_access_key.admin_key.id}
aws_secret_access_key = ${aws_iam_access_key.admin_key.secret}

EOF

  filename = "${var.user_home}/.aws/credentials"
}


output "admin_access_key" {
    value = "${aws_iam_access_key.admin_key.id}"
}

output "admin_secret_key" {
    value = "${aws_iam_access_key.admin_key.secret}"
}

