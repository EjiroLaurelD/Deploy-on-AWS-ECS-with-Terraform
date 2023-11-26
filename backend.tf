terraform {
  backend "s3" {
    bucket = "HCD"
    region = "eu-west-1"
    key = "myapp/terraform.tfstate"
  }
}

