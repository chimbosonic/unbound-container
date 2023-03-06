# Unbound OCI image
![pipeline status](https://github.com/chimbosonic/unbound-container/actions/workflows/main.yml/badge.svg?branch=main)

This is a unbound OCI image built using https://github.com/NLnetLabs/unbound.

This image has a fully setup unbound server that is configured for Recursive Resolution (It does not use any other DNS provider just the dns roots). It also blocks Ad and malware domains. Unbound will run unprivileged in the container and listen port 5353 for UDP and TCP. 

Base image is alpine:latest.

The image can be pulled from the following repositories:
- Docker Hub [here](https://hub.docker.com/repository/docker/chimbosonic/unbound)
- Quay.io [here](https://quay.io/repository/chimbosonic/unbound)

Source code and pipeline can be found [here](https://github.com/chimbosonic/unbound-container)

## Image Verification
The image is signed using [cosign](https://github.com/sigstore/cosign) from sigstore.

You can verify the signature with:
```bash
cosign verify --key cosign.pub chimbosonic/unbound:latest
```

## Running it
### plain docker

```bash
docker run -it  --rm -p 53:5353/tcp -p 53:5353/udp --name unbound chimbosonic/unbound:latest
```

### docker-compose
Please read docker-compose.yml before running the following

```bash
docker-compose up -d
```

### How to build
This will build the container.

```bash
make build
```

# CAUTION
The default config inside this container has been made to suit my needs:
  - 4 threads
  - IPv6 and IPv4 enabled both listenning and for queries
  - Blacklists advertising domains and malware domains
  - Any IP can make a query !! (This might not be secure in your environment. I use a firewall to block unwanted access)

You can overwite these by mounting `/var/unbound/etc` and putting in your configs inside the mounted volume. Or changing the config and building the image yourself using `make build`
