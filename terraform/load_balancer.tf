resource "digitalocean_certificate" "discourse-cert" {
  name              = "discourse-gabe-tech-cert"
  private_key       = file("/etc/letsencrypt/live/discourse.gabe.tech/privkey.pem")
  leaf_certificate  = file("/etc/letsencrypt/live/discourse.gabe.tech/cert.pem")
  certificate_chain = file("/etc/letsencrypt/live/discourse.gabe.tech/fullchain.pem")

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_loadbalancer" "discourse" {
  name   = "discourse-loadbalancer-1"
  region = "nyc1"

  redirect_http_to_https = true
  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.discourse-cert.name
  }

  healthcheck {
    port     = 80
    protocol = "tcp"
  }

  sticky_sessions {
    type               = "cookies"
    cookie_name        = "DOLBSESS"
    cookie_ttl_seconds = 7200
  }

  droplet_ids = digitalocean_droplet.discourse_ha[*].id
}
