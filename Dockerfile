FROM alpine:latest

LABEL maintainer="alexis.lowe@protonmail.com"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="chimbosonic/unbound"
LABEL org.label-schema.description="unbound container"
LABEL org.label-schema.vcs-url="https://gitlab.com/chimbosonic/unbound-container"
LABEL org.label-schema.vcs-ref=$VCS_REF

RUN apk update && apk add --no-cache bash

WORKDIR /var/unbound/etc
COPY config /var/unbound/etc

COPY installer.sh ./
RUN chmod +x installer.sh && ./installer.sh

USER unbound
EXPOSE 5353

RUN unbound-checkconf ./unbound.conf
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD drill -p 5353 @127.0.0.1 a.root-servers.net || exit 1

ENTRYPOINT ["/sbin/tini","--","unbound"]

CMD ["-dd","-c","/var/unbound/etc/unbound.conf"]
