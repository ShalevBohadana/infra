output "instance_ids" {
  description = "List of all EC2 instance IDs"
  value       = aws_instance.node[*].id
}

output "instance_public_ips" {
  description = "List of public IP addresses for EC2 instances"
  value       = aws_instance.node[*].public_ip
}
