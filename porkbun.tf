#
# Porkbun DNS A record.
#
# The only public Terraform provider for Porkbun
# (cullenmcdermott/porkbun, last release v0.3.0 / Nov 2024) is broken:
# Porkbun's API now returns the record `id` as a JSON object, but the
# provider still unmarshals it into an int, which aborts `terraform apply`
# with:  "cannot unmarshal object into Go struct field createResponse.id
#         of type int".
# The upstream repo has been archived (Nov 2025) and is no longer
# maintained, so we manage the A record via the Porkbun REST API directly
# from a `local-exec` provisioner. The record is reconciled on every
# `terraform apply` whenever the instance IP or domain changes.
#

resource "null_resource" "porkbun_a_record" {
  triggers = {
    instance_ip = vultr_instance.rustr-org.main_ip
    domain      = var.porkbun_domain
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/porkbun_a_record.sh"
    interpreter = ["bash", "-c"]

    environment = {
      PORKBUN_API_BASE   = "https://api.porkbun.com/api/json/v3"
      PORKBUN_DOMAIN     = var.porkbun_domain
      PORKBUN_CONTENT    = vultr_instance.rustr-org.main_ip
      PORKBUN_API_KEY    = var.porkbun_api_key
      PORKBUN_SECRET_KEY = var.porkbun_secret_key
    }
  }
}
