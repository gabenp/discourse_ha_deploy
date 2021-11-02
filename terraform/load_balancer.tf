resource "digitalocean_loadbalancer" "discourse" {
  name   = "discourse-loadbalancer-1"
  region = "nyc1"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 80
    protocol = "tcp"
  }

  droplet_ids = digitalocean_droplet.discourse_ha[*].id
}
