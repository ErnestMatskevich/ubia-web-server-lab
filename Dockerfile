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
    && curl -fsSLO "https://nginx.org/keys/arut.key" \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && gpg --import arut.key \
    && gpg --batch --fingerprint 43387825DDB1BB97EC36BA5D007C8D7C15D87369 \
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
        openssl \
        libpcre2-8-0 \
        zlib1g \
        libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY html/ /usr/local/nginx/html/

RUN mkdir -p /usr/local/nginx/conf/certs \
    && openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
        -keyout /usr/local/nginx/conf/certs/aaa.st14.sne22.ru.key \
        -out /usr/local/nginx/conf/certs/aaa.st14.sne22.ru.crt \
        -subj "/CN=aaa.st14.sne22.ru" \
        -addext "subjectAltName=DNS:aaa.st14.sne22.ru" \
    && openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
        -keyout /usr/local/nginx/conf/certs/bbb.st14.sne22.ru.key \
        -out /usr/local/nginx/conf/certs/bbb.st14.sne22.ru.crt \
        -subj "/CN=bbb.st14.sne22.ru" \
        -addext "subjectAltName=DNS:bbb.st14.sne22.ru"

RUN /usr/local/nginx/sbin/nginx -t

EXPOSE 8080 8443

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
