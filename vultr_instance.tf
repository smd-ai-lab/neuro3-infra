resource "vultr_ssh_key" "default" {
  name    = "rustr-org-ssh-key"
  ssh_key = file("~/.ssh/id_rsa.pub")

  lifecycle {
    ignore_changes = [ssh_key]
  }
}

resource "vultr_instance" "rustr-org" {
  region         = local.default_region
  plan           = "vc2-2c-4gb"
  os_id          = 2284
  label          = "rustr-org-vm"
  hostname       = "rustr-org-host"
  ssh_key_ids    = [vultr_ssh_key.default.id]
  vpc_ids        = [vultr_vpc.default_vpc.id]
  reserved_ip_id = vultr_reserved_ip.default.id
}

resource "vultr_reserved_ip" "default" {
  region  = local.default_region
  ip_type = "v4"
}
