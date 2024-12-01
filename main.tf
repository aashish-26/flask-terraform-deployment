resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC62xC6aWTQ2QdpjjSx2Awzet5Ww4NnsoOhgn4JBv4+GDkUaOvxM3+2ZRH1HRZjNWYaD4bm0Hsj1IpQRYFEMjTy45vU3F77NY9s1u1zN8FwgoRVyhCg5Y5dzRgAT0iR+9e4CKz4mVKKfMFTMsEQAemt5x0UUPowjqosOrOP2f03Ga2n14Mjsona+tfBQY4pGc2qOitosEuezSANg1uEhkw1gJrD3Vu9XXuSjZoaPklE2YctacOFPE3eA+Lz7Zz0g7YZym5GiI9e5G8BVP2VZqTshEqF3tVyqKbC8nm14j/tPz6p5iY6wfdFDvqQMwhloRtOAo0fG4V22HomeP8xqUDxhILJgBCTP1YCVhsbDBWBvwrxta3T8/6TAPlXSa5Puho6V2LG1x2wXWds4NyApK2ZA8OJCwLJUcrdBVHYurlAAzEOJ4o5AgS0S4+OglW66Q+nA0z34N3FC+UWDX/dFnKgZxGuwvvz4TNYjjNg/xwjTl2knt15zukJUJJ/p94fkx8= aashish bhandari@LAPTOP-7UU56LSM"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true  //used in the configuration of an AWS subnet to specify whether instances launched within that subnet should automatically be assigned a public IP address.
  tags = {
    Name = "tf-example"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "example-route-table"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.example
  route_table_id = aws_route_table.example_route_table
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-0dee22c13ea7a9a67"
  instance_type          = "t2.micro"
  key_name      = aws_key_pair.deployer
  vpc_security_group_ids = [aws_security_group.webSg]
  subnet_id              = aws_subnet.example

 connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("C:\\Users\\Aashish bhandari\\.ssh\\id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
}