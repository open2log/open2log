# Managing infrastructure with opentofu and sops

## Opentofu remote backend

See more in: https://developers.cloudflare.com/terraform/advanced-topics/remote-backend/

First login to Cloudflare and enable 'Add R2 subscription to my account'

Then check that secrets/infra.yml has CLOUDFLARE_API_TOKEN.

Then run: 
```
# Create R2 bucket with the EU jurisdiction into West Europe
$ sops exec-env secrets/infra.yaml 'wrangler r2 bucket create infra-state --jurisdiction eu'
```

Then https://dash.cloudflare.com/?to=/:account/r2/overview and create new S3 style access and secret keys to get started storing state in remote file.

If you get following issue, it most likely means that your ipv6 address has changed and you need to modify the [R2 access allowed IP-listing](https://dash.cloudflare.com/?to=/:account/r2/api-tokens).

```
Successfully configured the backend "s3"! OpenTofu will automatically
use this backend unless the backend configuration changes.
Error refreshing state: operation error S3: HeadObject, https response error StatusCode: 403, RequestID: , HostID: , api error Forbidden: Forbidden
```

## Sops

### Adding new members

```sh
# Generate new key using MacOS secure enclave
age-plugin-se keygen --access-control=any-biometry -o ~/.config/sops/age/secure-enclave-key.txt

# Get the public key
cat ~/.config/sops/age/secure-enclave-key.txt | grep public | grep -o 'age1se[[:alnum:]]*'
```

Then add the public key into `.sops.yaml` as new user.
Then regenerate all secret files so that the new user can read them:

```sh
sops -r -i --add-age ${NEW-PUBLIC-AGE-KEY-HERE} secrets/infra.yaml
```

### Editing secrets

```sh
sops edit secrets/infra.yaml
```

### Limiting IP-access to the keys
Let's assume that the keys might accidentally leak even though they are encrypted in SOPS. You can limit using them into only certain IP-addresses here with Hetzner:

https://robot.hetzner.com/preferences/index

