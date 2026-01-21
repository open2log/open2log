resource "hrobot_ssh_key" "onnimonni" {
  name       = "onnimonni"
  public_key = file("keys/onnimonni.pub")
}

resource "hrobot_server" "main" {
  server_type = "Server Auction"
  server_id   = var.hetzner_auction_server_id
  server_name = "memento-mori"

  # These are used only for the initial deployment
  authorized_keys = [hrobot_ssh_key.onnimonni.fingerprint]

  public_net {
    ipv4_enabled = true
  }
}

output "ip" {
  description = "Main ipv4 address of the server"
  value = hrobot_server.main.public_net.ipv4
}