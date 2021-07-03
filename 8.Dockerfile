FROM adoptopenjdk:8-jre-hotspot as webp-lib-build
RUN apt update && apt install -y \
                  curl
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
        amd64|x86_64) \
            curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64; \
            curl -LO https://github.com/itzg/rcon-cli/releases/download/1.4.8/rcon-cli_1.4.8_linux_amd64.tar.gz; \
            tar -zxvf rcon-cli_1.4.8_linux_amd64.tar.gz; \
            ;; \
        aarch64|arm64) \
            curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_aarch64; \
            curl -LO https://github.com/itzg/rcon-cli/releases/download/1.4.8/rcon-cli_1.4.8_linux_arm64.tar.gz; \
            tar -zxvf rcon-cli_1.4.8_linux_arm64.tar.gz; \
            ;; \
        *) \
            echo だめ; \
            exit 1; \
            ;; \
    esac;



FROM adoptopenjdk:8-jre-hotspot
LABEL org.opencontainers.image.source = "https://github.com/tmswar/jvm-and"

COPY --from=webp-lib-build --chmod=755 /rcon-cli /rcon-cli

ENV LD_LIBRARY_PATH=/usr/local/lib/

RUN apt update && apt install -y \
    iputils-ping

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
STOPSIGNAL 2
