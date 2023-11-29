terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.39.0"
    }
  }
}

#########################
# VARIABLES SETUP
#########################
variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

variable "ssh_keys" {
  description = "SSH key fingerprints for nodes"
  type = map(string)
}

variable "network_ip_range" {
  description = "IP range for the VNet"
  default = "10.0.0.0/16"
}

variable "subnet_ip_range" {
  description = "IP range for the subnet"
  default = "10.0.0.0/24"
}

variable "subnet_type" {
  description = "Type of the subnet"
  default = "cloud"
}

variable "subnet_network_zone" {
  description = "Network zone of the subnet"
  default = "eu-central"
}

variable "placement_group_name" {
  description = "Name of the placement group"
  default = "spread-group"
}

variable "placement_group_type" {
  description = "Type of the placement group"
  default = "spread"
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "vnet" {
  name     = "vnet"
  ip_range = var.network_ip_range
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.vnet.id
  type         = var.subnet_type
  network_zone = var.subnet_network_zone
  ip_range     = var.subnet_ip_range
}

resource "hcloud_placement_group" "spread-group" {
  name = var.placement_group_name
  type = var.placement_group_type
}

data "hcloud_ssh_key" "ssh_key" {
  for_each = var.ssh_keys
  fingerprint = each.value
}

#########################
# SERVER RESOURCES SETUP
#########################
resource "hcloud_server" "master-1" {
  name        = "master-1"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.ssh_key["master"].id]
  server_type = "cx41"
  firewall_ids = [hcloud_firewall.firewall.id]
  placement_group_id = hcloud_placement_group.spread-group.id
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.vnet.id
    ip         = "10.0.0.2"
  }
}

#resource "hcloud_server" "master-2" {
#  name        = "master-2"
#  image       = "ubuntu-20.04"
#  location    = "nbg1"
#  ssh_keys    = [data.hcloud_ssh_key.ssh_key["master"].id]
#  server_type = "cx41"
#  firewall_ids = [hcloud_firewall.firewall.id]
#  placement_group_id = hcloud_placement_group.spread-group.id
#  public_net {
#    ipv4_enabled = true
#    ipv6_enabled = true
#  }
#  network {
#    network_id = hcloud_network.vnet.id
#    ip         = "10.0.0.4"
#  }
#}

resource "hcloud_server" "worker-1" {
  name        = "worker-1"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.ssh_key["worker"].id]
  server_type = "ccx13"
  firewall_ids = [hcloud_firewall.firewall.id]
  placement_group_id = hcloud_placement_group.spread-group.id
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.vnet.id
    ip         = "10.0.0.3"
  }
}

#resource "hcloud_server" "worker-2" {
#  name        = "worker-2"
#  image       = "ubuntu-20.04"
#  location    = "nbg1"
#  ssh_keys    = [data.hcloud_ssh_key.ssh_key["worker"].id]
#  server_type = "ccx22"
#  firewall_ids = [hcloud_firewall.firewall.id]
#  placement_group_id = hcloud_placement_group.spread-group.id
#  public_net {
#    ipv4_enabled = true
#    ipv6_enabled = true
#  }
#  network {
#    network_id = hcloud_network.vnet.id
#    ip         = "10.0.0.4"
#  }
#}

#resource "hcloud_server" "worker-3" {
#  name        = "worker-3"
#  image       = "ubuntu-20.04"
#  location    = "nbg1"
#  ssh_keys    = [data.hcloud_ssh_key.ssh_key["worker"].id]
#  server_type = "ccx22"
#  firewall_ids = [hcloud_firewall.firewall.id]
#  placement_group_id = hcloud_placement_group.spread-group.id
#  public_net {
#    ipv4_enabled = true
#    ipv6_enabled = true
#  }
#  network {
#    network_id = hcloud_network.vnet.id
#    ip         = "10.0.0.5"
#  }
#}
#
#resource "hcloud_server" "worker-4" {
#  name        = "worker-4"
#  image       = "ubuntu-20.04"
#  location    = "nbg1"
#  ssh_keys    = [data.hcloud_ssh_key.ssh_key["worker"].id]
#  server_type = "ccx12"
#  firewall_ids = [hcloud_firewall.firewall.id]
#  placement_group_id = hcloud_placement_group.spread-group.id
#  public_net {
#    ipv4_enabled = true
#    ipv6_enabled = true
#  }
#  network {
#    network_id = hcloud_network.vnet.id
#    ip         = "10.0.0.7"
#  }
#}

#resource "hcloud_server" "worker-5" {
#  name        = "worker-5"
#  image       = "ubuntu-20.04"
#  location    = "nbg1"
#  ssh_keys    = [data.hcloud_ssh_key.ssh_key["worker"].id]
#  server_type = "ccx22"
#  firewall_ids = [hcloud_firewall.firewall.id]
#  placement_group_id = hcloud_placement_group.spread-group.id
#  public_net {
#    ipv4_enabled = true
#    ipv6_enabled = true
#  }
#  network {
#    network_id = hcloud_network.vnet.id
#    ip         = "10.0.0.8"
#  }
#}

#
#resource "hcloud_server" "worker-6" {
#  name        = "worker-6"
#  image       = "ubuntu-20.04"
#  location    = "nbg1"
#  ssh_keys    = [data.hcloud_ssh_key.ssh_key["worker"].id]
#  server_type = "ccx12"
#  firewall_ids = [hcloud_firewall.firewall.id]
#  placement_group_id = hcloud_placement_group.spread-group.id
#  public_net {
#    ipv4_enabled = true
#    ipv6_enabled = true
#  }
#  network {
#    network_id = hcloud_network.vnet.id
#    ip         = "10.0.0.9"
#  }
#}

# master-1

#########################
# OUTPUTS
#########################
# master
output "master1_ip" {
  value = hcloud_server.master-1.ipv4_address
}
output "master1_private_ip" {
  value = [for n in hcloud_server.master-1.network: n.ip][0]
}

// worker-1
output "worker1_ip" {
  value = hcloud_server.worker-1.ipv4_address
}
output "worker1_private_ip" {
  value = [for n in hcloud_server.worker-1.network: n.ip][0]
}

// worker-2
#output "worker2_ip" {
#  value = hcloud_server.worker-2.ipv4_address
#}
#output "worker2_private_ip" {
#  value = [for n in hcloud_server.worker-2.network: n.ip][0]
#}

#########################
# FIREWALL SETUP
#########################
resource "hcloud_firewall" "firewall" {
  name = "rancher-rke2-cluster-firewall"
  ## Inbound rules
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9345"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "3128"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "3128"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "5672"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "5672"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  ## Outbound rules
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "53"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "53"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "123"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "80"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "443"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "443"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "icmp"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  ## Outbound rules for couchbase (TCP)
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "8091"
    description = "Couchbase TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "8092"
    description = "Couchbase TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "8093"
    description = "Couchbase TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "8094"
    description = "Couchbase TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "11210"
    description = "Couchbase TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  ## Outbound rules for couchbase (UDP)
  rule {
    direction = "out"
    protocol  = "udp"
    port      = "8091"
    description = "Couchbase UDP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "8092"
    description = "Couchbase UDP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "8093"
    description = "Couchbase UDP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "8094"
    description = "Couchbase UDP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "11210"
    description = "Couchbase UDP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  // Outbound rules for Neo4j (TCP)
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "7474"
    description = "Neo4j TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "7473"
    description = "Neo4j TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "7687"
    description = "Neo4j TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "3128"
    description = "Squid-Proxy TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "3128"
    description = "Squid-Proxy UDP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "5672"
    description = "RabbitMQ TCP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "5672"
    description = "RabbitMQ UDP"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

}