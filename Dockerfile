# syntax = docker/dockerfile:1.5

FROM rust:1.71-alpine3.18 as builder

# Install tools and deps
RUN apk update && \
apk --no-cache upgrade && \
apk add --no-cache \
    alpine-sdk \
    bash \
    binutils \
    ca-certificates \
    clang \
    cmake \
    gcc \
    git \
    libc-dev \
    linux-headers \
    nodejs \
    npm \
    openssh-client \
    openssl \
    openssl-dev \
    python3 \
    zeromq-dev

# Configure Node.js
RUN npm install -g npm@latest && \
    npm install -g corepack@latest && \
    corepack prepare yarn@stable --activate && \
    corepack enable

# Install sccache for caching
ENV SCCACHE_VERSION=0.4.2
RUN if [[ "$TARGETARCH" == "arm64" ]] ; then export SCC_ARCH=aarch64; else export SCC_ARCH=x86_64; fi; \
    curl -Ls \
        https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${SCC_ARCH}-unknown-linux-musl.tar.gz | \
        tar -C /tmp -xz && \
        mv /tmp/sccache-*/sccache /usr/local/bin/

# Configure Rust
RUN rustup toolchain install stable && \
    rustup target add wasm32-unknown-unknown --toolchain stable && \
    cargo install -f wasm-bindgen-cli@0.2.86
