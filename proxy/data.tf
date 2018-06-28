data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config {
    key     = "aweg.state"
    bucket  = "aweg-state"
    region  = "us-west-2"
    profile = "${var.aws_profile}"
  }
}
