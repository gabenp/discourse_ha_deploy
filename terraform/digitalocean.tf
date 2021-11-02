resource "digitalocean_droplet" "discourse_ha" {
  count     = 2
  image     = "ubuntu-20-04-x64"
  name      = "discourse-${count.index}"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  user_data = file("./droplet_user_data.txt")
}

resource "digitalocean_database_cluster" "discourse" {
  name       = "discourse-pg"
  engine     = "pg"
  version    = "13"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
}

resource "digitalocean_database_db" "discourse_db" {
  cluster_id = digitalocean_database_cluster.discourse.id
  name       = "discourse"
}
