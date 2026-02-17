output "public_ip_address"{
    value = aws_instance.Jenkins.public_ip
}