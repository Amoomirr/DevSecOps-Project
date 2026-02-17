output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]
}

output "aws_security_group" {
  value = aws_security_group.netflix_sg.id
}
