FROM adoptopenjdk:16-jre-hotspot as webp-lib-build
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

RUN apt update && apt install -y \
    build-essential curl \
    libjpeg-dev libpng-dev libtiff-dev libgif-dev mercurial; \
    \
    set -eux; \
    curl -LO https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.2.0.tar.gz ; \
    tar xvzf libwebp-1.2.0.tar.gz ; \
    cd libwebp-1.2.0 ; \
    ./configure ; \
    make; \
    make install;


FROM adoptopenjdk:16-jre-hotspot
LABEL org.opencontainers.image.source = "https://github.com/tms-war/jvm-and"

COPY --from=webp-lib-build --chmod=755 /usr/local/bin/* /usr/local/bin/
COPY --from=webp-lib-build --chmod=755 /usr/local/lib/* /usr/local/lib/
COPY --from=webp-lib-build --chmod=755 /usr/local/include/webp /usr/local/include/webp
COPY --from=webp-lib-build --chmod=755 /rcon-cli /rcon-cli

ENV LD_LIBRARY_PATH=/usr/local/lib/

RUN apt update && apt install -y \
    libjpeg-dev libpng-dev libtiff-dev libgif-dev \
    iputils-ping

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
STOPSIGNAL 2
