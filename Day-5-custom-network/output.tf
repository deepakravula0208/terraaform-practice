output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = values(aws_subnet.private)[*].id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs (if any)"
  value       = var.enable_nat ? aws_nat_gateway.nat[*].id : []
}

output "bastion_sg_id" {
  description = "Security group ID for bastion SSH"
  value       = aws_security_group.bastion.id
}
