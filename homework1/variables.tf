variable "region" {
  description = "AWS region for VMs"
  default     = "us-east-1"
}

variable "private_key_path" {}

variable "key_name" {}

variable "ami" {
  description = "ami (ubuntu 18) to use - based on region"
  default = {
    "us-east-1" = "ami-00ddb0e5626798373"
    "us-east-2" = "ami-0dd9f0e7df0f0a138"
  }
}

variable "userdata_server" {
  description = "user data to be executed by servers"
  default     = <<-EOF
  #! /bin/bash

  sudo apt update

  # install and run consul as a service
  sudo chmod +x /tmp/consul.sh
  sudo /tmp/consul.sh
  EOF
}

variable "userdata_agent" {
  description = "user data to be executed by agents"
  default     = <<-EOF
  #! /bin/bash

  sudo apt update

  # install and run consul as a service
  sudo chmod +x /tmp/consul.sh
  sudo /tmp/consul.sh

  # install nginx
  sudo apt install nginx -y
  sudo service nginx restart

  # register service to consul
  sudo cp /tmp/webserver_service.json /etc/consul.d/
  consul reload

  EOF
}
