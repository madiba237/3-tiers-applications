resource "aws_vpc" "alain_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true 
  tags = {
    Name = "alain_vpc"
  }
  
}

resource "aws_internet_gateway" "alain_vpc_igw" {
  vpc_id = aws_vpc.alain_vpc.id
  
  tags = {
    Name = "alain_vpc_igw"
  }
}


resource "aws_nat_gateway" "alain_vpc_ngw" {
  allocation_id = aws_eip.alain_vpc_eip.id
  subnet_id = aws_subnet.alain_vpc_public_subnet.id
  tags = {
    Name = "alain_vpc_ngw"
  }

}

resource "aws_eip" "alain_vpc_eip" {
  depends_on = [ aws_internet_gateway.alain_vpc_igw ]
  tags = {
    Name = "alain_vpc_eip"
  }
}


resource "aws_subnet" "alain_vpc_public_subnet" {
  vpc_id = aws_vpc.alain_vpc.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
  tags ={
    Name = "alain_vpc_public_subnet"
  }
}


resource "aws_subnet" "alain_vpc_private_redis_subnet" {
  vpc_id = aws_vpc.alain_vpc.id
  cidr_block = "10.0.12.0/24"

  tags = {
    Name = "alain_vpc_private_subnet_redis" 
  }

}


resource "aws_subnet" "alain_vpc_private_db_subnet" {
  vpc_id = aws_vpc.alain_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "alain_vpc_private_subnet_db" 
  }

}

resource "aws_route_table" "alain_vpc_public_rt" {
  vpc_id = aws_vpc.alain_vpc.id
  

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alain_vpc_igw.id
    
  }
  tags = {
    Name = "alain_vpc_public_rt"
  }
}

resource "aws_route_table" "alain_vpc_private_redis_rt" {
  vpc_id = aws_vpc.alain_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.alain_vpc_ngw.id 
  }
  tags = {
    Name = "alain_vpc_private_redis_rt"
  }
}

resource "aws_route_table" "alain_vpc_private_db_rt" {
  vpc_id = aws_vpc.alain_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.alain_vpc_ngw.id 
  }
  tags = {
    Name = "alain_vpc_private_db_rt"
  }
}

resource "aws_route_table_association" "alain_vpc_public_rt_association" {
  subnet_id = aws_subnet.alain_vpc_public_subnet.id
  route_table_id = aws_route_table.alain_vpc_public_rt.id
}


resource "aws_route_table_association" "alain_vpc_private_redis_rt_association" {
  subnet_id = aws_subnet.alain_vpc_private_redis_subnet.id
  route_table_id = aws_route_table.alain_vpc_private_redis_rt.id
}

resource "aws_route_table_association" "alain_vpc_private_db_rt_association" {
  subnet_id = aws_subnet.alain_vpc_private_db_subnet.id
  route_table_id = aws_route_table.alain_vpc_private_db_rt.id
}

resource "aws_security_group" "alain_vpc_public_sg" {
  name        = "alain_vpc_public_vote_result_sg"
  description = "Security group for public subnet"
  vpc_id = aws_vpc.alain_vpc.id


  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  

  

  ingress  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alain_vpc_public_sg"
  }
}


resource "aws_security_group" "alain_vpc_private_redis_sg" {
  name        = "alain_vpc_private_redis_worker_sg"
  description = "Security group for private subnet"
  vpc_id = aws_vpc.alain_vpc.id


  
  
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.alain_vpc_public_sg.id]
    description     = "Allow Redis traffic from Frontend"
  }
   

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.alain_vpc_public_sg.id ]
    description = "Allow SSH access from Frontend"
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  


}


 resource "aws_security_group" "alain_vpc_private_db_sg" {
  name        = "alain_vpc_private_db_sg"
  description = "Security group for private subnet"
  vpc_id = aws_vpc.alain_vpc.id

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.alain_vpc_public_sg.id ]
  }


  
   ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [ aws_security_group.alain_vpc_private_redis_sg.id ]
    description = "Allow PostgreSQL traffic from Backend"
  }
 
  
 }