FROM alpine:3.19
RUN apk add --no-cache openjdk17 && \
    apk add --no-cache jq && \
    wget https://github.com/keycloak/keycloak/releases/download/23.0.2/keycloak-23.0.2.tar.gz && \
    tar -xvzf keycloak-23.0.2.tar.gz

ENV PATH="$PATH:/keycloak-23.0.2/bin"

COPY init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]