# terraform/ssh-sg.tf

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow SSH from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH from my laptop"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    # Replace with your real public IP/32
    cidr_blocks      = ["203.0.113.17/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
