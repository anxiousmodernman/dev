

terraform {
  backend "s3" {
    key = "aweg.state"
    region = "us-west-2"
    dynamodb_table = "aweg-tfstatelock"
  }
}
