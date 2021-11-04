# discourse_ha_deploy terraform

### Prereqs

1. Configure DO authentication for terraform
```
export TF_VAR_do_token=<token>
```

### Manual bootstrapping

1. Configure `discourse.gabe.tech` DNS outside of this terraform
2. Manual LetsEncrypt certificate generation via `certbot`
3. Configure admin account directly without any email provider

### Maintenance

To rebuild instances, do it one at a time and allow the instance to bootstrap before proceeding:

```
terraform apply -target digitalocean_loadbalancer.discourse -target digitalocean_droplet.discourse_ha[0]

... wait for instance `-0` to be fully bootstrapped ...

terraform apply -target digitalocean_loadbalancer.discourse -target digitalocean_droplet.discourse_ha[1]
```

For discourse version upgrades: ???
