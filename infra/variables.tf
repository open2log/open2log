variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  sensitive   = false # FIXME: turn back to true
}

variable "hetzner_auction_server_id" {
  description = "Server ID for our auction server"
  type        = number
  sensitive   = false # FIXME: turn back to true
}

variable "hetzner_storage_box_admin_password" {
  description = "Admin password for the storage box"
  type        = string
  sensitive   = false # FIXME: turn back to true
}
