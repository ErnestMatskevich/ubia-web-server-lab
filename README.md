# UBIA Web Server Lab

nginx is built from source in the Dockerfile and serves two name-based virtual hosts.

## Ports

HTTP runs on port `8080`.

HTTPS runs on port `8443`.

The HTTPS certificates are self-signed and generated during the Docker image build. Because they are self-signed, use `curl -k` when testing.

To test nginx TLS directly on Railway, use a Railway TCP Proxy that forwards to container port `8443`. Railway's normal HTTP/HTTPS edge terminates TLS before traffic reaches the container, so it is not suitable for verifying nginx's own TLS configuration.
