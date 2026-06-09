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

resource "null_resource" "install_kind" {
  depends_on = [null_resource.install_docker]

  triggers = {
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
      "ARCH=$(uname -m)",
      "if [ \"$ARCH\" = 'x86_64' ]; then",
      "  curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-amd64",
      "elif [ \"$ARCH\" = 'aarch64' ]; then",
      "  curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-arm64",
      "else",
      "  echo 'Unsupported architecture: $ARCH' && exit 1",
      "fi",
      "chmod +x /usr/local/bin/kind",
      "kind version",
    ]
  }
}

resource "null_resource" "install_helm" {
  depends_on = [null_resource.install_kind]

  triggers = {
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
      "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get-helm-3.sh",
      "chmod +x /tmp/get-helm-3.sh",
      "/tmp/get-helm-3.sh",
      "helm version",
    ]
  }
}

resource "null_resource" "install_kubectl" {
  depends_on = [null_resource.install_helm]

  triggers = {
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
      "ARCH=$(uname -m)",
      "if [ \"$ARCH\" = 'x86_64' ]; then",
      "  curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "elif [ \"$ARCH\" = 'aarch64' ]; then",
      "  curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl",
      "else",
      "  echo 'Unsupported architecture: $ARCH' && exit 1",
      "fi",
      "chmod +x /usr/local/bin/kubectl",
      "kubectl version --client",
    ]
  }
}

resource "null_resource" "setup_env_vars" {
  depends_on = [null_resource.install_kubectl]

  triggers = {
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
      "echo 'OPENAI_API_KEY=${var.openai_api_key}' >> /etc/environment",
      "echo 'export OPENAI_API_KEY=${var.openai_api_key}' > /etc/profile.d/openai.sh",
      "echo 'OPENAI_ORGANIZATION_ID=${var.openai_organization_id}' >> /etc/environment",
      "echo 'export OPENAI_ORGANIZATION_ID=${var.openai_organization_id}' > /etc/profile.d/openai.sh",
      "echo 'OPENAI_URL=${var.openai_url}' >> /etc/environment",
      "echo 'export OPENAI_URL=${var.openai_url}' > /etc/profile.d/openai.sh",
      "chmod +x /etc/profile.d/openai.sh",
    ]
  }
}

resource "null_resource" "install_kagent" {
  depends_on = [null_resource.setup_env_vars]

  triggers = {
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
      "curl -fsSL https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash",
      "kagent version",
    ]
  }
}
