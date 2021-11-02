resource "digitalocean_database_cluster" "discourse" {
  name       = "discourse-pg"
  engine     = "pg"
  version    = "13"
  size       = "db-s-1vcpu-2gb" # Needs >1gb for HA sizing
  region     = "nyc1"
  node_count = 2
}

resource "digitalocean_database_db" "discourse_db" {
  cluster_id = digitalocean_database_cluster.discourse.id
  name       = "discourse"
}

resource "digitalocean_database_user" "discourse" {
  cluster_id = digitalocean_database_cluster.discourse.id
  name       = "discourse"
}

resource "digitalocean_database_connection_pool" "discourse-pool-01" {
  cluster_id = digitalocean_database_cluster.discourse.id
  name       = "discourse-pool-01"
  mode       = "transaction"
  size       = 20
  db_name    = "discourse"
  user       = "discourse"
}
