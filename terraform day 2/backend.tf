terraform {
  backend "s3" {
    bucket = "s3terraformbuckets3"
    key="day3/terraform.tfstate"
    region = "us-east-1"
  }
}