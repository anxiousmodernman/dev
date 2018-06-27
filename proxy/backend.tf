terraform {
  backend "s3" {
    bucket         = "aweg-state"
    key            = "aweg.state"
    region         = "us-west-2"
    dynamodb_table = "aweg-tfstatelock"
  }
}
