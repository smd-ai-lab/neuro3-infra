output "vultr_account_info" {
  value = data.vultr_account.current
}

output "default_region" {
  value = local.default_region
}

output "vultr_instance_ip" {
  value = vultr_instance.rustr-org.main_ip
}

output "porkbun_dns_record" {
  value = null_resource.porkbun_a_record.id
}
