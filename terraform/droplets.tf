# Create a new SSH key
resource "digitalocean_ssh_key" "root" {
  name       = "Home Desktop"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "discourse_ha" {
  count     = 2
  image     = "ubuntu-20-04-x64"
  name      = "discourse-${count.index}"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  user_data = file("./droplet_user_data.txt")
  ssh_keys  = [digitalocean_ssh_key.root.id]
}
