resource "aws_instance" "nat_instance" {
  for_each                    = var.subnets
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[each.key].id
  vpc_security_group_ids      = [aws_security_group.nat[each.key].id]
  associate_public_ip_address = true

  source_dest_check = false

  # Bash script to automate iptables and IP forwarding configuration on boot
  user_data = <<-EOF
              #!/bin/bash
              # 1. Habilita IP Forwarding de forma persistente
              echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/custom-ip.conf
              sudo sysctl --system

              # 2. Descobre dinamicamente o nome da interface de rede publica (ex: eth0 ou ens5)
              PUB_INTERFACE=$(ip route show | awk '/default/ {print $5}')

              # 3. Instala e inicia o iptables-services
              sudo dnf install iptables-services -y
              sudo systemctl enable iptables
              sudo systemctl start iptables

              # 4. Configura o NAT Masquerade na interface correta encontrada
              sudo iptables -F
              sudo iptables -t nat -F
              sudo iptables -P FORWARD ACCEPT
              sudo iptables -t nat -A POSTROUTING -o $PUB_INTERFACE -j MASQUERADE
              sudo service iptables save
              EOF


  tags = {
    Name      = "${var.project_name}_nat_${each.key}"
    SSMAccess = true
  }
}
