resource "digitalocean_database_cluster" "discourse" {
  name       = "discourse-pg"
  engine     = "pg"
  version    = "13"
  size       = "db-s-1vcpu-2gb" # Needs >1gb for HA sizing
  region     = "nyc1"
  node_count = 2
}

resource "digitalocean_database_firewall" "discourse" {
  cluster_id = digitalocean_database_cluster.discourse.id

  dynamic "rule" {
    for_each = toset(digitalocean_droplet.discourse_ha[*].id)
    content {
      type  = "droplet"
      value = rule.value
    }
  }
}

resource "digitalocean_database_user" "discourse" {
  cluster_id = digitalocean_database_cluster.discourse.id
  name       = "discourse"
}
