terraform {
  backend "s3" {
    bucket         = "aweg-state"
    key            = "aweg.state.proxy"
    region         = "us-west-2"
    dynamodb_table = "aweg-tfstatelock"
  }
}

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "us-west-2"
}
