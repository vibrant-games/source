terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.14.0"
    }
  }
}

variable "do_personal_access_token" {}
variable "do_ssh_private_key_file"  {}

provider "digitalocean" {
  token = var.do_personal_access_token
}

data "digitalocean_ssh_key" "do_terraform" {
  name = "jtienhaara@yahoo.com"
}

#
# For now just a single webserver VM.
# (Eventually Kubernetes cluster with Istio etc.)
#
resource "digitalocean_droplet" "web" {
  image = "ubuntu-20-04-x64"
  name = "web"
  region = "tor1"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.do_terraform.id
  ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.do_ssh_private_key_file)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # Install nginx:
      "sudo apt update",
      "sudo apt install -y nginx"
    ]
  }
}
