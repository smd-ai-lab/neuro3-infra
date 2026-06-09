resource "null_resource" "install_docker" {
  depends_on = [vultr_instance.rustr-org]

  triggers = {
    # Re-run if the instance is replaced.
    instance_id = vultr_instance.rustr-org.id
  }

  connection {
    type        = "ssh"
    host        = vultr_instance.rustr-org.main_ip
    user        = "root"
    private_key = file("${path.module}/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "curl -fsSL https://get.docker.com -o /tmp/get-docker.sh",
      "sh /tmp/get-docker.sh",
      "systemctl enable --now docker",
      "docker --version",
      "docker compose version",
    ]
  }
}
