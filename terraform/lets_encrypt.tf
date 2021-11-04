// NS records for test.gabe.tech configured manually outside of this project

resource "digitalocean_domain" "test" {
  name = "test.gabe.tech"
}

resource "digitalocean_record" "test" {
  domain = digitalocean_domain.test.name
  type   = "A"
  name   = "static"
  value  = digitalocean_loadbalancer.test-le-lb.ip
}

resource "digitalocean_certificate" "test-cert" {
  name    = "test-le-cert"
  type    = "lets_encrypt"
  domains = ["static.test.gabe.tech"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_loadbalancer" "test-le-lb" {
  name     = "test-le-lb"
  region   = "nyc1"

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.test-cert.name
  }

  healthcheck {
    port     = 80
    protocol = "tcp"
  }

  droplet_ids = digitalocean_droplet.discourse_ha[*].id
}

