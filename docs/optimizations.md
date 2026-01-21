# Optimizations

## Bandwidth and data storage
We assume that eventually this app will consume a lot of data. More cheaper we can store it the better because then we can keep the membership fees small and serve most of the world.

### Solving with R2
Cloudflare R2 has free egress with fair usage policy.

But storing data does cost 15.36$/1Tb/month =~ 13.12€/1Tb/month

> [There are no charges for egress bandwidth for any storage class.](https://developers.cloudflare.com/r2/pricing/#:~:text=There%20are%20no%20charges%20for%20egress%20bandwidth%20for%20any%20storage%20class.)

This is also great because it's a global option and Hetzner mainly has the cheap services in Europe.

### Solving with Hetzner
Storing data in Hetzner storage box costs 10.90€+VAT/5Tb/month =~ 2.18/1Tb/month. This is raid storage but data loss can still happen. It's slower but probably good enough in most cases.

Storing data in Object storage costs 4.99€+VAT/1Tb/month. [It has 10Gbit/s connection](https://docs.hetzner.com/storage/object-storage/overview/#limits) and [it should be much more durable than storage box](https://docs.hetzner.com/storage/general/which-storage-is-right-for-me/#overview).

If this starts to actually get any meaningful traffic most optimal system looks like storing lot of data in Hetzner object storage and then automatically provisioning the cheapest VPS servers with 20Tb traffic included. They can then cache most used files in the 40gb SSDs they have.

Hetzner storagebox has:
* 10 parallel maximum connections
* Speeds were not downgraded at least when I used 2 simultaneous connections
* Upload speed 1.1 Gbps
* Download speed 1.4 Gbps

Hetzner object storage has:
* Unlimited connections
* Download speed 3.18 Gbps (It's 10Gbps connection so the VPS seems to just be limited)
* Upload speed without multipart 0.9 Gbps
* Upload speed with multipart 0.52 Gbps

Tests were done on the cheapest VPS Hetzner has.

The cheapest VPS without ipv4 costs 2.99€+VAT per month per 20Tb outgoing traffic and maybe the VPS servers can function as crawlers when they are not used or when they have reached most of their traffic for month.

Proxying the traffic through cloudflare should be still okay.

One can directly use the Object storage but it costs 1€/Tb for traffic.

[Internal traffic inside Europe between VPS servers and Object Storage is free.](https://docs.hetzner.com/storage/object-storage/overview/#pricing)

So in conclusion it seems that duplicating data to multiple storageboxes would probably be the best at least in the beginning.

### Sharing data through p2p networks
Because the data itself is public we can share it from clients to another clients. Because the data is partitioned based on geo location the local users will always have the right data in the right place.

Discover more how eg bittorent could work with this. We might need to run our own tracker to actually achieve this.