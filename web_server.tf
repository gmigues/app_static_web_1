
resource "aws_instance" "web_server" {
  ami             = "ami-0ff591da048329e00"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = "dev_terraform"
  user_data       = <<EOF
#!/bin/bash
cd /home/ubuntu
sudo apt update -y
sudo apt install python3 python3-full python3-flask -y
git clone https://github.com/gmigues/time-app.git
cd time-app
python3 app.py
EOF

  tags = {
    Name = "web-server_1"
  }
  depends_on = [aws_lb.web_lb]
}



resource "aws_instance" "bastion" {
  ami             = "ami-0ff591da048329e00"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_a.id
  security_groups = [aws_security_group.bastion_sg.id]
  key_name        = "dev_terraform"


  tags = {
    Name = "bastion"
  }
  depends_on = [aws_lb.web_lb]
}






resource "aws_instance" "web_server_2" {
  ami             = "ami-0ff591da048329e00"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_b.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = "dev_terraform"
  user_data       = <<EOF
#!/bin/bash
cd /home/ubuntu
sudo apt update -y
sudo apt install python3 python3-full python3-flask -y
git clone https://github.com/gmigues/time-app.git
cd time-app
python3 app.py
EOF

  tags = {
    Name = "web-server_2"
  }
  depends_on = [aws_lb.web_lb]
}
