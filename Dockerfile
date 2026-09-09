FROM debian:bookworm-slim AS builder

ARG NGINX_VERSION=1.30.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        build-essential \
        libpcre2-dev \
        zlib1g-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN curl -fsSLO "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && curl -fsSLO "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc" \
    && curl -fsSLO "https://nginx.org/keys/nginx_signing.key" \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && gpg --import nginx_signing.key \
    && gpg --batch --fingerprint 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && gpg --batch --verify "nginx-${NGINX_VERSION}.tar.gz.asc" "nginx-${NGINX_VERSION}.tar.gz" \
    && rm -rf "$GNUPGHOME" \
    && tar -xzf "nginx-${NGINX_VERSION}.tar.gz"

WORKDIR /tmp/nginx-${NGINX_VERSION}

RUN ./configure \
        --prefix=/usr/local/nginx \
        --with-http_ssl_module \
    && make \
    && make install

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpcre2-8-0 \
        zlib1g \
        libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY html/index.html /usr/local/nginx/html/index.html

EXPOSE 8080

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
