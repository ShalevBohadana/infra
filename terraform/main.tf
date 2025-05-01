###########################################################
# 1) Provider & Data Sources
###########################################################
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

###########################################################
# 2) SSH Key Pair (existing)
###########################################################

resource "aws_key_pair" "ansible" {
  key_name   = var.key_name
  public_key = file("C:/Users/heave/.ssh/${var.key_name}.pub")
}

###########################################################
# 3) VPC Module
###########################################################
module "vpc" {
  source          = "./modules/vpc"
  name            = "portfolio-vpc"
  cidr_block      = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
}

###########################################################
# 4) SSH-only Security Group
###########################################################
resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow SSH from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["46.116.192.140/32"] # ← replace with YOUR public IP/32
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###########################################################
# 5) Compute Module (Master + Workers)
###########################################################

module "compute" {
  source = "./modules/compute"
  name           = "k3s-node"
  instance_count = var.instance_count
  ami            = data.aws_ami.ubuntu.id
  instance_type  = var.instance_type
  subnet_ids     = module.vpc.public_subnet_ids
  key_name       = var.key_name
  tags           = { Project = "portfolio-demo" }

  security_group_ids = [
    aws_security_group.portfolio.id
  ]
}


###########################################################
# 6) Jenkins Server (Standalone EC2)
###########################################################

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = var.key_name
 vpc_security_group_ids = [aws_security_group.portfolio.id]
  tags = { Role = "jenkins" }
}

resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  vpc      = true
}

output "jenkins_public_ip" {
  description = "Elastic IP attached to the Jenkins server"
  value       = aws_eip.jenkins.public_ip
}
# Attach an IGW to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "internet-gateway"
  }
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Associate that route table with each public subnet
resource "aws_route_table_association" "public_subnets" {
  count          = length(module.vpc.public_subnet_ids)
  subnet_id      = element(module.vpc.public_subnet_ids, count.index)
  route_table_id = aws_route_table.public.id
}
