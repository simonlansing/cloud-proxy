# Cloud proxy based on WireGuard and Traefik

This cloud proxy configuration is intended to make local services available that are located behind a carrier-grade NAT. For this purpose, a Traefik instance is started up in the cloud (or wherever an external IP is available) together with a WireGuard peer, which forwards requests coming from outside via WireGuard to a local onsite Traefik instance.

In addition, the Traefik instances are configured to automatically encrypt all requests, domains and subdomains with TLS (via Let's Encrypt, ACME and DNS-01 challenge with Cloudflare DNS) and to authorize these requests via Traefik Forward Auth (using the Google Auth service).

## Cloud

Create an .env file in folder cloud with following content:

```
BASE_FQDN=example.com
AUTH_CLIENT_ID=<exampleId>.apps.googleusercontent.com
AUTH_CLIENT_SECRET=<exampleClientSecret>
AUTH_SECRET=<exampleSecret>
CLOUDFLARE_DNS_API_TOKEN=<cloudflareDnsApiToken>
CLOUDFLARE_ZONE_API_TOKEN=<cloudflareZoneApiToken>
TRAEFIK_CERTIFICATESRESOLVERS_CFRESOLVER_ACME_EMAIL=<acmeEmail>
WIREGUARD_PEERS=peer0,peer1,peer2,peer3
TRAEFIK_DNS_MAP_0=traefik-peer0:10.0.0.2
TRAEFIK_DNS_MAP_1=traefik-peer1:10.0.0.3
TRAEFIK_DNS_MAP_2=traefik-peer2:10.0.0.4
TRAEFIK_DNS_MAP_3=traefik-peer3:10.0.0.5
```

### WireGuard

To allow the two Traefiks to communicate with each other via WireGuard, the WireGuard interfaces on both sides still need to be configured. Otherwise the Ethernet frames that are sent via Traefik are too large. As statet in [Wireguard mailing list](https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html)

> The overhead of WireGuard breaks down as follows:
>
> - 20-byte IPv4 header or 40 byte IPv6 header
> - 8-byte UDP header
> - 4-byte type
> - 4-byte key index
> - 8-byte nonce
> - N-byte encrypted data
> - 16-byte authentication tag
>
> So, if you assume 1500 byte ethernet frames, the worst case (IPv6)
> winds up being 1500-(40+8+4+4+8+16), leaving N=1420 bytes. However, if
> you know ahead of time that you're going to be using IPv4 exclusively,
> then you could get away with N=1440 bytes.

To solve this problem, add the following lines to wg0.conf:

```
[Interface]
MTU = 1420
```

## Onsite

Create an .env file in folder onsite with following content. `SERVER_CONFIG` is an example on how to configure proxying multiple services through the onsite traefik. Each service consists of a triple: `<url_prefix>,<local_ip_port>,<boolean>`:

- `url_prefix` is used as the subdomain for the service on this peer
- `local_ip_port` is the url to which traefik should route to
- `boolean` value defines if the access to the subdomain should be guarded by the forward auth (based on Google Auth right now)

```
BASE_FQDN=example.com
BASE_FQDN_PREFIX=peer0
SERVER_CONFIG=traefik,api@internal,true%home,http://192.168.20.10:8123,false%printer,http://192.168.10.12,true%proxmox,https://192.168.0.10:8006,true%opnsense,https://192.168.10.1,true%synology,https://192.168.10.11:5551,true%adguard,http://192.168.0.1:3000,true%unifi,https://192.168.10.10:8443,true
AUTH_CLIENT_ID=<exampleId>.apps.googleusercontent.com
AUTH_CLIENT_SECRET=<exampleClientSecret>
AUTH_SECRET=<exampleSecret>
CLOUDFLARE_DNS_API_TOKEN=<cloudflareDnsApiToken>
CLOUDFLARE_ZONE_API_TOKEN=<cloudflareZoneApiToken>
TRAEFIK_CERTIFICATESRESOLVERS_CFRESOLVER_ACME_EMAIL=<acmeEmail>
```

### WireGuard

As with the WireGuard cloud peer, the MTU size in the WireGuard interface of the onsite peer must also be reduced. In addition, the onsite peer must keep the channel to the cloud peer "open" so that the cloud peer can forward requests to the onsites. Add following lines to wg0.conf:

```
[Interface]
MTU = 1420

[Peer]
PersistentKeepalive = 25
```
