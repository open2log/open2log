{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Strict firewall - only allow Cloudflare IPs for HTTP/HTTPS
  # Reference: https://www.cloudflare.com/ips/

  networking.firewall = {
    enable = true;

    # Default deny all incoming
    allowedTCPPorts = [ 22 ]; # SSH only for management

    # Allow HTTP/HTTPS only from Cloudflare IP ranges
    # These should be updated periodically
    extraCommands = ''
      # Cloudflare IPv4 ranges
      for ip in 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 \
                141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 \
                197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 \
                104.24.0.0/14 172.64.0.0/13 131.0.72.0/22; do
        iptables -A INPUT -p tcp -s $ip --dport 80 -j ACCEPT
        iptables -A INPUT -p tcp -s $ip --dport 443 -j ACCEPT
      done

      # Cloudflare IPv6 ranges
      for ip in 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 \
                2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32; do
        ip6tables -A INPUT -p tcp -s $ip --dport 80 -j ACCEPT
        ip6tables -A INPUT -p tcp -s $ip --dport 443 -j ACCEPT
      done
    '';

    extraStopCommands = ''
      # Clean up Cloudflare rules
      iptables -F INPUT 2>/dev/null || true
      ip6tables -F INPUT 2>/dev/null || true
    '';
  };

  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "24h";
    bantime-increment = {
      enable = true;
      maxtime = "168h"; # 1 week max ban
    };
  };
}
