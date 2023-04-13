# syntax = docker/dockerfile:1.5
# Build wasm-dpp
# TODO(wasm-dpp): implement custom Docker image to build mixed projects with rust/wasm/JS
# Image has to be based on `rust` image, have wasm-bindgen-cli and wasm32-unknown targets preinstalled
# and also have `node` and `yarn` to build JS part of wasm-dpp
FROM rust:alpine3.16 as builder

ARG NODE_ENV=production
ENV NODE_ENV ${NODE_ENV}

RUN apk update && \
    apk --no-cache upgrade && \
    apk add --no-cache curl nodejs npm && \
    npm install -g npm@latest && \
    npm install -g corepack@latest && \
    corepack prepare yarn@stable --activate && \
    corepack enable

# RUN yarn config set enableInlineBuilds true

ARG TARGETARCH

ARG CARGO_BUILD_PROFILE=debug
ENV CARGO_BUILD_PROFILE ${CARGO_BUILD_PROFILE}

ARG SCCACHE_GHA_ENABLED
ARG ACTIONS_CACHE_URL
ARG ACTIONS_RUNTIME_TOKEN

# Activate sccache for Rust code
ENV RUSTC_WRAPPER=/usr/local/bin/sccache
# Disable incremental buildings, not supported by sccache
ENV CARGO_INCREMENTAL=false

# Install sccache for caching
ENV SCCACHE_VERSION=0.4.1
RUN if [[ "$TARGETARCH" == "arm64" ]] ; then export SCC_ARCH=aarch64; else export SCC_ARCH=x86_64; fi; \
    curl -Ls \
        https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${SCC_ARCH}-unknown-linux-musl.tar.gz | \
        tar -C /tmp -xz && \
        mv /tmp/sccache-*/sccache /usr/local/bin/

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
        openssh-client \
        openssl-dev \
        python3 \
        zeromq-dev

RUN rustup toolchain install stable && \
    rustup target add wasm32-unknown-unknown --toolchain stable && \
    cargo install -f wasm-bindgen-cli
