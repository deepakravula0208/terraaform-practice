terraform {
  backend "s3" {
    bucket = "s3buckets3"
    key    = "terraform.tfstate"
    #use_lockfile = true # to use s3 native locking 1.19 version above
    region = "us-east-1"
    dynamodb_table = "veera" # any version we can use dynamodb locking 
    encrypt = true
  }
}