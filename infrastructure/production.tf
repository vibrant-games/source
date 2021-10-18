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

# !!! #
# !!! # For now just a single webserver VM.
# !!! # (Eventually Kubernetes cluster with Istio etc.)
# !!! #
# !!! resource "digitalocean_droplet" "web" {
# !!!   image = "ubuntu-20-04-x64"
# !!!   name = "web"
# !!!   region = "tor1"
# !!!   size = "s-1vcpu-1gb"
# !!!   ssh_keys = [
# !!!     data.digitalocean_ssh_key.do_terraform.id
# !!!   ]
# !!! 
# !!!   connection {
# !!!     host = self.ipv4_address
# !!!     user = "root"
# !!!     type = "ssh"
# !!!     private_key = file(var.do_ssh_private_key_file)
# !!!     timeout = "2m"
# !!!   }
# !!! 
# !!!   provisioner "remote-exec" {
# !!!     inline = [
# !!!       "export PATH=$PATH:/usr/bin",
# !!!       # Install nginx:
# !!!       "sudo apt update",
# !!!       "sudo apt install -y nginx"
# !!!     ]
# !!!   }
# !!! }


#
# DNS currently done by hand :(
# Need to re-jig the domain stuff to use Terraform,
# and move all of the email etc domain records into here.
#
# !!! resource "digitalocean_domain" "vibrantgames_ca" {
# !!!   name = "vibrantgames.ca"
# !!!   # !!! ip_address = digitalocean_loadbalancer.web.iv4_address
# !!! }

# IP address is of the load balancer spun up in Kubernetes:
resource "digitalocean_record" "www_vibrantgames_ca" {
  # !!! domain = digitalocean_domain.vibrantgames_ca.name
  domain = "vibrantgames.ca"
  type = "A"
  name = "www"
  value = "104.248.105.225"
}

resource "digitalocean_certificate" "certificate_production_www" {
  # !!! name = "production-2021-10-10"
  name = "certificate-production-www"
  type = "lets_encrypt"
  domains = [ "www.vibrantgames.ca" ]
}

# !!! resource "digitalocean_certificate" "certificate_production" {
# !!!   # !!! name = "production-2021-10-10"
# !!!   name = "certificate-production"
# !!!   type = "lets_encrypt"
# !!!   domains = [ digitalocean_domain.www_vibrantgames_ca.name ]
# !!! }

# !!! resource "digitalocean_loadbalancer" "web" {
# !!!   name = "web-load-balancer"
# !!!   region = "tor1"
# !!! 
# !!!   forwarding_rule {
# !!!     entry_port = 443
# !!!     entry_protocol = "https"
# !!! 
# !!!     target_port = 80
# !!!     target_protocol = "http"
# !!! 
# !!!     certificate_name = digitalocean_certificate.certificate_production.name
# !!!   }
# !!! 
# !!!   healthcheck {
# !!!     port = 22
# !!!     protocol = "tcp"
# !!!   }
# !!! 
# !!!   droplet_ids = [ digitalocean_droplet.web.id ]
# !!! }



#
# Adapted from https://github.com/ponderosa-io/tf-digital-ocean-cluster/blob/master/digital-ocean-cluster.tf
#

data "digitalocean_kubernetes_versions" "version" {
  #
  # At the time of writing, 1.21.3-do.0 is available.
  #
  version_prefix = "1.21."
}

resource "digitalocean_kubernetes_cluster" "production" {
  name    = "production"
  region  = "tor1"

  version = data.digitalocean_kubernetes_versions.version.latest_version
  auto_upgrade = true

  #
  # High availability control plane:
  # NOT supported in tor1 data centre
  #
  # ha = true

  # !!! tags

  maintenance_policy {
    day = "thursday"

    # UTC.  EST=UTC-5, EDT=UTC-4.
    # So 6:00 = 1am-5am winter, 2am-6am summer Eastern time.
    start_time = "6:00"
  }

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
    # !!! auto_scale = true
    # !!! min_nodes = 1
    # !!! max_nodes = 5
    # !!! tags
    # !!! labels
  }
}

#
# Container registry for private images:
#
resource "digitalocean_container_registry" "vibrantgames_production_registry" {
  name = "vibrantgames-production-registry"
  subscription_tier_slug = "starter"
  # !!! endpoint = "registry.digitalocean.com/myregistry"
  # !!! server_url = "registry.digitalocean.com"
}

output "cluster-id" {
  value = digitalocean_kubernetes_cluster.production.id
}

output "certificate-uuid" {
  value = digitalocean_certificate.certificate_production_www.uuid
}
