terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.14.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.5.1"
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
  type = "CNAME"
  name = "www"
  value = "@"
}

resource "digitalocean_certificate" "certificate_production_www" {
  # !!! name = "production-2021-10-10"
  name = "certificate-production-www"
  type = "lets_encrypt"
  domains = [ "www.vibrantgames.ca" ]
}


#
# The following is adapted from
# https://github.com/ponderosa-io/tf-digital-ocean-cluster/blob/master/digital-ocean-cluster.tf
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

  #
  # Patch versions will be upgraded.
  # (x.y.z -> x.y.z+1.)
  #
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
    # !!! Not used yet:
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
resource "digitalocean_container_registry" "production_registry" {
  name = "production-registry"
  subscription_tier_slug = "starter"

  #
  # Read-only:
  #   endpoint = "registry.digitalocean.com/myregistry"
  #   server_url = "registry.digitalocean.com"
  #
}

#
# Update the Kubernetes cluster to pull from the container registry:
#
resource "digitalocean_container_registry_docker_credentials" "production_registry" {
  registry_name = digitalocean_container_registry.production_registry.name
}

provider "kubernetes" {
  host = digitalocean_kubernetes_cluster.production.endpoint
  token = digitalocean_kubernetes_cluster.production.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.production.kube_config[0].cluster_ca_certificate
  )
}

# !!! This will fail if run before kubectl apply has happened. :(
resource "kubernetes_secret" "container-registry-secret" {
  metadata {
    name = "docker-cfg"
    namespace = "www"
  }

  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.production_registry.docker_credentials
  }

  type = "kubernetes.io/dockerconfigjson"
}


output "cluster-id" {
  value = digitalocean_kubernetes_cluster.production.id
}

output "certificate-uuid" {
  value = digitalocean_certificate.certificate_production_www.uuid
}

output "container-registry-server-url" {
  value = digitalocean_container_registry.production_registry.server_url
}
