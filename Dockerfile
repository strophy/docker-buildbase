# syntax = docker/dockerfile:1.5
# Build wasm-dpp
# TODO(wasm-dpp): implement custom Docker image to build mixed projects with rust/wasm/JS
# Image has to be based on `rust` image, have wasm-bindgen-cli and wasm32-unknown targets preinstalled
# and also have `node` and `yarn` to build JS part of wasm-dpp
FROM rust:alpine3.17 as builder

ARG NODE_ENV=production
ENV NODE_ENV ${NODE_ENV}

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.16/main' >> /etc/apk/repositories
RUN apk update && \
    apk --no-cache upgrade && \
    apk add --no-cache nodejs=16.20.0-r0 npm && \
    npm install -g npm@latest && \
    npm install -g corepack@latest && \
    corepack prepare yarn@stable --activate && \
    corepack enable

# RUN yarn config set enableInlineBuilds true

ARG CARGO_BUILD_PROFILE=debug
ENV CARGO_BUILD_PROFILE ${CARGO_BUILD_PROFILE}

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

RUN --mount=type=cache,target=target \
    --mount=type=cache,target=$CARGO_HOME/git \
    --mount=type=cache,target=$CARGO_HOME/registry \
    rustup target add wasm32-unknown-unknown && \
    cargo install -f wasm-bindgen-cli
