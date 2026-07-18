data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

locals {
  user_data_sudo_nopasswd = <<-EOT
    #!/bin/bash
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-ansible-users
    chmod 0440 /etc/sudoers.d/90-ansible-users
  EOT
}

resource "aws_instance" "alain_frontend_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.alain_vpc_public_subnet.id
  vpc_security_group_ids = [aws_security_group.alain_vpc_public_sg.id]
  key_name = "alain_key"
  user_data              = local.user_data_sudo_nopasswd

  tags                   = { 
    Name = "Frontend-Bastion-Instance"
    Role = "Frontend"
    Environment = "Production"
   }

}

resource "aws_instance" "alain_backend_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.alain_vpc_private_redis_subnet.id
  vpc_security_group_ids = [aws_security_group.alain_vpc_private_redis_sg.id]
  key_name = "alain_key"
  user_data              = local.user_data_sudo_nopasswd
  tags                   = { Name = "Backend-Worker-Instance" 
                             Role = "Backend"
                             Environment = "Production"
                             }
}

resource "aws_instance" "alain_backend_db_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.alain_vpc_private_db_subnet.id
  vpc_security_group_ids = [aws_security_group.alain_vpc_private_db_sg.id]
  key_name = "alain_key"
  user_data              = local.user_data_sudo_nopasswd

  tags                   = { Name = "PostgreSQL-Instance" 
                             Role = "Database" 
                             Environment = "Production"
                             }
}