terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    hrobot = {
      source  = "midwork-finds-jobs/hrobot"
      version = "~> 0.1.0"
    }
    hcloud = {
      source  = "hashicorp/hcloud"
      version = "~> 1.59"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  # Token comes from CLOUDFLARE_API_TOKEN env var via sops
  #  api_token = var.cloudflare_api_token
}

provider "hrobot" {
  # Credentials come from $HROBOT_USERNAME and $HROBOT_PASSWORD
}

provider "hcloud" {
  # Token comes from HCLOUD_TOKEN env var via sops
}
