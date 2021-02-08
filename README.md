# Unbound Container
![pipeline status](https://gitlab.com/chimbosonic/unbound-container/badges/master/pipeline.svg)

This container has a fully setup unbound server that is configured for Recursive Resolution (It does not use any other DNS provider just the dns roots).

Base image is alpine:latest.

The image is available on Docker Hub [here](https://hub.docker.com/repository/docker/chimbosonic/unbound)

## Running it
### plain docker
Feel free to change the port and folder that contains your repos.

```bash
docker run -it  --rm -p 5353:5353 --name unbound -t chimbosonic/unbound:latest
```

### docker-compose
Please read docker-compose.yml before running the following

```bash
docker-compose up -d
```
This should make unbound available on port `53`

### How to build
This will build the container.

```bash
make build
```

# CAUTION
The default config inside this container has been made to suit my needs:
  - 4 threads
  - IPv6 and IPv4 enabled both listenning and for queries
  - Some Local Zones have been enabled (.internal)
  - Blacklists advertising domains and malware domains
  - Any IP can make a query !! (This might not be secure in your environment. I use a firewall to block unwanted access)

You can overwite these by mounting `/var/unbound/etc` and putting in your configs inside the mounted volume.