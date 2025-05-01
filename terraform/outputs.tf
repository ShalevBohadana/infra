output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "compute_instance_public_ips" {
  description = "Public IPs of your K3s nodes"
  value       = module.compute.instance_public_ips
}

output "ansible_key_name" {
  description = "Name of the imported SSH key"
  value       = aws_key_pair.ansible.key_name
}
