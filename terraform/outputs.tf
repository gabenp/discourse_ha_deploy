output "droplet_ip_addr" {
  value = digitalocean_droplet.discourse_ha[*].ipv4_address
}
