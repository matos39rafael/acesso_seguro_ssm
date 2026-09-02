output "vpc_id" {
  value = aws_vpc.principal.id
}

output "public_subnets_id" {
  value = {
    for key, subnet in aws_subnet.public :
    key => subnet.id
  }
}

output "private_app_subnet_id" {
  value = {
    for key, subnet in aws_subnet.private_app :
    key => subnet.id
  }
}

output "private_db_subnet_id" {
  value = {
    for key, subnet in aws_subnet.private_db :
    key => subnet.id
  }
}

output "nat_instance_id" {
  value = {
    for key, instance in aws_instance.nat_instance :
    key => instance.id
  }
}

output "nat_public_ip" {
  value = {
    for key, instance in aws_instance.nat_instance :
    key => instance.public_ip
  }
}

output "private_app_instance_id" {
  value = {
    for key, instance in aws_instance.private_app :
    key => instance.id
  }
}

output "private_app_instance_private_ip" {
  value = {
    for key, instance in aws_instance.private_app :
    key => instance.private_ip
  }
}

output "ssm_user_policy_arn" {
  value = aws_iam_policy.ssm_user.arn
}
