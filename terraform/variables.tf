variable "key_name" {
  description = "Name of your SSH keypair (must exist in ~/.ssh/*.pub)"
  type        = string
}

variable "instance_count" {
  description = "How many K3s nodes to spin up"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "EC2 instance type for K3s nodes"
  type        = string
  default     = "t3.small"
}
