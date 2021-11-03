# Create a new SSH key
resource "digitalocean_ssh_key" "root" {
  name       = "Home Desktop"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "discourse_ha" {
  count    = 2
  image    = "ubuntu-20-04-x64"
  name     = "discourse-${count.index}"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.root.id]
  user_data = templatefile(
    "./templates/droplet_user_data.tpl",
    {
      doadmin_defaultdb_uri = digitalocean_database_cluster.discourse.uri
      discourse_db_host     = digitalocean_database_cluster.discourse.host
      discourse_db_port     = digitalocean_database_cluster.discourse.port
      discourse_db_user     = digitalocean_database_user.discourse.name
      discourse_db_pass     = digitalocean_database_user.discourse.password
  })
}
