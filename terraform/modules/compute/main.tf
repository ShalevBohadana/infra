 resource "aws_instance" "node" {
   count                  = var.instance_count
   ami                    = var.ami
   instance_type          = var.instance_type
   subnet_id              = element(var.subnet_ids, count.index)
   key_name               = var.key_name
   vpc_security_group_ids = var.security_group_ids

  # ensure each node gets a public IPv4 address
 associate_public_ip_address = true

   tags = merge(
     var.tags,
     { Name = "${var.name}-${count.index}" }
   )
 }
