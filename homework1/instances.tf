resource "aws_instance" "consul_server" {
  count         = 3
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.opsschool_consul.id]

  user_data = var.userdata_server

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "scripts/consul-server.sh"
    destination = "/tmp/consul.sh"
  }

  tags = {
    Name          = "opsschool-server-${count.index}"
    consul_server = "true"
  }

}

resource "aws_instance" "consul_agent" {

  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.opsschool_consul.id]

  user_data = var.userdata_agent

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "scripts/consul-agent.sh"
    destination = "/tmp/consul.sh"
  }

  provisioner "file" {
    source      = "consul.d/webserver_service.json"
    destination = "/tmp/webserver_service.json"
  }

  tags = {
    Name = "opsschool-agent"
  }
}

output "server" {
  value = aws_instance.consul_server[*].public_dns
}

output "agent" {
  value = aws_instance.consul_agent.public_dns
}
