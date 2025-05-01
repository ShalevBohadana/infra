variable "name" {
  description = "Base name for tagging instances"
  type        = string
}

variable "instance_count" {
  type    = number
}

variable "ami" {
  type    = string
}

variable "instance_type" {
  type    = string
}

variable "subnet_ids" {
  type    = list(string)
}

variable "key_name" {
  type    = string
}

variable "security_group_ids" {    # ← exactly this name
  description = "List of SG IDs to attach to compute instances"
  type        = list(string)
}

variable "tags" {
  type        = map(string)
  default     = {}
}
