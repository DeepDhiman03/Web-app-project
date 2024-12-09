resource "aws_instance" "backend" {
  ami           = "ami-0e2c8caa4b6378d8c" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.id]

  user_data = filebase64("./ec2-user-data.sh")

  key_name = "abc"
    tags = {
    Name = "backend-Server"
  }

}

