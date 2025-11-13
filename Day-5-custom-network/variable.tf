variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "Availability zones to use (ordered)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDRs for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDRs for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat" {
  description = "Create NAT Gateways (one per AZ) for private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Owner       = "terraform"
    Environment = "dev"
  }
}
