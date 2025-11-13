# adjust these values to match your needs & region
region = "us-east-1"
azs = ["us-east-1a", "us-east-1b"]
vpc_cidr = "10.0.0.0/16"

public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

enable_nat = true

tags = {
  Owner       = "team-a"
  Environment = "dev"
}
