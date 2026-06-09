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

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
}

variable "openai_organization_id" {
  description = "OpenAI Organization ID"
  type        = string
  sensitive   = true
}

variable "openai_url" {
  description = "OpenAI API URL"
  type        = string
  default     = "https://api.openai.com/v1"
}
