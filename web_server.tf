
resource "aws_instance" "web_server" {
  ami             = "ami-0ff591da048329e00"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = "dev_terraform"
  user_data       = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
echo "Hello World from Terraform. Web server 1" > /var/www/html/index.html
sudo systemctl stop apache2
sudo systemctl start apache2
EOF

  tags = {
    Name = "web-server_1"
  }
}



resource "aws_instance" "web_server_2" {
  ami             = "ami-0ff591da048329e00"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_b.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = "dev_terraform"
  user_data       = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
echo "Hello World from Terraform. Web server 2" > /var/www/html/index.html
sudo systemctl stop apache2
sudo systemctl start apache2
EOF

  tags = {
    Name = "web-server_2"
  }
}
