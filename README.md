# Cloud Proxy based on WireGuard and Traefik

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

Add following lines to wg0.conf

```
[Interface]
MTU = 1384
```

## Onsite

Create an .env file in folder onsite with following content. `SERVER_CONFIG` is an example on how to configure proxying multiple services through the onsite traefik. Each service consists of a triple: `<url_prefix>,<local_ip_port>,<boolean>`:

- url_prefix is used as the subdomain for the service on this peer
- local_ip_port is the url to which traefik should route to
- boolean value defines if the access to the subdomain should be guarded by the forward auth (based on Google Auth right now)

```
BASE_FQDN=example.com
BASE_FQDN_PREFIX=peer0
SERVER_CONFIG=traefik,api@internal,true%home,http://192.168.20.10:8123,false%printer,http://192.168.10.12,true%proxmox,https://192.168.0.10:8006,true%opnsense,https://192.168.10.1,true%synology,https://192.168.10.11:5551,true%adguard,http://192.168.0.1:3000,true%unifi,https://192.168.10.10:8443,true
CLOUDFLARE_DNS_API_TOKEN=<cloudflareDnsApiToken>
CLOUDFLARE_ZONE_API_TOKEN=<cloudflareZoneApiToken>
TRAEFIK_CERTIFICATESRESOLVERS_CFRESOLVER_ACME_EMAIL=<acmeEmail>
```

### WireGuard

Add following lines to wg0.conf

```
[Interface]
MTU = 1384

[Peer]
PersistentKeepalive = 25
```
