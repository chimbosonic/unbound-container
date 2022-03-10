FROM golang:latest as blocklist

WORKDIR /root

RUN ln -s /usr/bin/python3 /usr/bin/python \
    && git clone --depth 1 https://github.com/opencoff/unbound-adblock.git \
    && cd unbound-adblock \
    && gmake

FROM alpine:latest

ARG ROOT_HINTS="https://www.internic.net/domain/named.root"
ARG ICANN_CERT="https://data.iana.org/root-anchors/icannbundle.pem"
ARG PUID="2000"
ARG PGID="2000"

WORKDIR /var/unbound/etc
COPY --from=blocklist /root/unbound-adblock/big.conf /var/unbound/etc/unbound.blacklist
COPY config /var/unbound/etc

RUN addgroup -g ${PGID} unbound \
    && adduser -D -u ${PUID} -G unbound unbound \
    && apk update \
    && apk add --no-cache tini drill curl unbound ca-certificates \
    && curl -q -o /var/unbound/etc/root.hints -SL ${ROOT_HINTS} \
    && chmod 0444 /var/unbound/etc/root.hints \
    && chown unbound:unbound /var/unbound/etc/root.hints \
    && curl -o /tmp/icannbundle.pem -SL ${ICANN_CERT} \
    && unbound-anchor -a /var/unbound/etc/root.key -c /tmp/icannbundle.pem -r /var/unbound/etc/root.hints || echo "Root Key was updated"  \
    && chmod 0444 /var/unbound/etc/root.key \
    && chown unbound:unbound /var/unbound/etc/root.key \
    && chown -R unbound:unbound /var/unbound \
    && rm -rf /tmp/* \
    && unbound-checkconf ./unbound.conf 

USER unbound
EXPOSE 5353

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD drill -p 5353 @127.0.0.1 a.root-servers.net || exit 1

ENTRYPOINT ["/sbin/tini","--","unbound"]

CMD ["-dd","-c","/var/unbound/etc/unbound.conf"]
