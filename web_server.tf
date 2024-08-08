
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
touch deploy_web.sh
chmod +x deploy_web.sh
echo """
#!/bin/bash
#


sudo pkill -f app.py 2>&1
cd /home/ubuntu/time-app
sudo git config --global --add safe.directory /home/ubuntu/time-app
sudo git pull
sudo nohup python3 app.py > app.log 2>&1 &
""" > deploy_web.sh
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
  user_data       = <<EOF
#!/bin/bash
cd /home/ubuntu
sudo apt update -y
touch deploy.sh
chmod +x deploy.sh
echo """
#!/bin/bash

# Commands to be executed on the remote server
REMOTE_COMMANDS='sudo /home/ubuntu/./deploy_web.sh 2>&1'

# Execute the commands on the remote server using SSH
ssh -i private_key ubuntu@10.0.3.77 "'\$REMOTE_COMMANDS'"
ssh -i private_key ubuntu@10.0.3.77 "'\$REMOTE_COMMANDS'"
""" > deploy.sh

EOF


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
touch deploy_web.sh
chmod +x deploy_web.sh
echo """
#!/bin/bash
#


sudo pkill -f app.py 2>&1
cd /home/ubuntu/time-app
sudo git config --global --add safe.directory /home/ubuntu/time-app
sudo git pull
sudo nohup python3 app.py > app.log 2>&1 &
""" > deploy_web.sh
cd time-app
python3 app.py
EOF

  tags = {
    Name = "web-server_2"
  }
  depends_on = [aws_lb.web_lb]
}
