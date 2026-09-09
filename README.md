# Unix-Based Internet Applications Web Server Lab

This project builds nginx from source inside a Debian Linux container. It does not use a prebuilt nginx image such as `nginx:alpine` or `nginx:latest`.

## Why Debian

The image starts from `debian:bookworm-slim` because it is a small, general-purpose Linux base image with straightforward build packages available through `apt`. This keeps the lab focused on downloading, verifying, compiling, and installing nginx ourselves.

## Why This Meets the Lab Requirement

The Dockerfile downloads the official nginx source archive from `https://nginx.org/download/`, downloads the matching `.asc` PGP signature, imports the official nginx signing key from `https://nginx.org/keys/nginx_signing.key`, checks the expected key fingerprint, verifies the archive, configures the build, compiles it with `make`, and installs it into `/usr/local/nginx`.

This satisfies the lab requirement better than using a ready-made nginx Docker image because the nginx binary is created during the Docker build instead of being copied from an existing nginx image.

## TLS Support

TLS support is enabled at compile time with:

```sh
--with-http_ssl_module
```

This builds nginx with the HTTP SSL module, although this first lab step does not configure HTTPS certificates yet.

## Build and Run Locally

Build the image:

```sh
docker build -t web-server-lab .
```

Run the container:

```sh
docker run --rm -p 8080:8080 web-server-lab
```

Open:

```text
http://localhost:8080
```
