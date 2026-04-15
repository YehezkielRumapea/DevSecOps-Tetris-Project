resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = "t3a.large"
  key_name               = var.key-name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  root_block_device {
    volume_size = 30
  }
  user_data = file("./tools-install.sh")

  tags = {
    Name = var.instance-name
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = "t3a.medium"
  key_name               = var.key-name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  root_block_device {
    volume_size = 20
  }
  user_data = file("./sonar-install.sh")

  tags = {
    Name = var.sonar-instance-name
  }
}