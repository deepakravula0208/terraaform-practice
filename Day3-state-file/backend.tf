terraform {
  backend "s3" {
    bucket         = "s3terraformbuckets3"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
 
  }
}
