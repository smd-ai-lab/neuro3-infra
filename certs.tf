resource "null_resource" "push_tls_certs" {
  triggers = {
    domain_cert_hash = filesha256("${path.module}/certs/domain.cert.pem")
    private_key_hash = filesha256("${path.module}/certs/private.key.pem")
  }

  provisioner "file" {
    source      = "${path.module}/certs/domain.cert.pem"
    destination = "/root/domain.cert.pem"
    connection {
      type        = "ssh"
      host        = vultr_instance.rustr-org.main_ip
      user        = "root"
      private_key = file("${path.module}/id_rsa")
    }
  }

  provisioner "file" {
    source      = "${path.module}/certs/private.key.pem"
    destination = "/root/private.key.pem"
    connection {
      type        = "ssh"
      host        = vultr_instance.rustr-org.main_ip
      user        = "root"
      private_key = file("${path.module}/id_rsa")
    }
  }
}
