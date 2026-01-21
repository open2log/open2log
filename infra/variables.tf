variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  sensitive   = true
}

variable "hrobot_username" {
  description = "Hetzner Robot WS username"
  type        = string
  sensitive   = true
}

variable "hrobot_password" {
  description = "Hetzner Robot WS password"
  type        = string
  sensitive   = true
}

variable "hetzner_auction_server_id" {
  description = "Server ID for our auction server"
  type        = number
  sensitive   = true
}

variable "hetzner_storage_box_admin_password" {
  description = "Admin password for the storage box"
  type        = string
  sensitive   = true
}
