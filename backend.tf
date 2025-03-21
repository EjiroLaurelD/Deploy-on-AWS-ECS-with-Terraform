terraform {
  backend "s3" {
    bucket = "hcd-spendsmart"
    region = "eu-west-2"
    key    = "spendsmart/terraform.tfstate"
  }
}

