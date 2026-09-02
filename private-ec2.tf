resource "aws_instance" "private_app" {
  for_each                    = var.subnets
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_app[each.key].id
  vpc_security_group_ids      = [aws_security_group.private_app.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name


  # Bash script to configure ssm agent
  user_data = <<-EOF
              #!/bin/bash

              set -eux

              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent

              EOF


  tags = {
    Name      = "${var.project_name}_private_app_${each.key}"
    SSMAccess = true

  }
}
