#KEY PAIR
resource "aws_key_pair" "mtc_auth" {
  key_name   = ""
  public_key = file("") #(Create the Config File)
}

#EC2 INSTANCE (NEED TO UPDATE THE USERDATA)
resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg_2.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata_2.tpl") #(Update the file to install Ansible)

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "dev-node"
  }
}

resource "aws_instance" "worker_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata_3.tpl")

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "worker-node"
  }
}

resource "aws_instance" "worker_node_2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet_2.id
  user_data              = file("userdata_3.tpl")

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "worker-node 2"
  }
}
