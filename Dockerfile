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
    
# Disable incremental buildings, not supported by sccache
ENV CARGO_INCREMENTAL=false

# Configure Rust
RUN rustup toolchain install stable && \
    rustup target add wasm32-unknown-unknown --toolchain stable && \
    cargo install -f wasm-bindgen-cli
