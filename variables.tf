variable "vultr_api_key" {
  description = "API key for Vultr provider"
  type        = string
  sensitive   = true
}

variable "porkbun_api_key" {
  description = "API key for Porkbun provider"
  type        = string
  sensitive   = true
}

variable "porkbun_secret_key" {
  description = "Secret API key for Porkbun provider"
  type        = string
  sensitive   = true
}

variable "porkbun_domain" {
  description = "Domain name for the application"
  type        = string
}
