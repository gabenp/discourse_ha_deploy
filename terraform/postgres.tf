resource "digitalocean_database_cluster" "discourse" {
  name       = "discourse-pg"
  engine     = "pg"
  version    = "13"
  size       = "db-s-1vcpu-2gb" # Needs >1gb for HA sizing
  region     = "nyc1"
  node_count = 2
}
