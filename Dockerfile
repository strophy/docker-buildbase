# syntax = docker/dockerfile:1.5
# Build wasm-dpp
# TODO(wasm-dpp): implement custom Docker image to build mixed projects with rust/wasm/JS
# Image has to be based on `rust` image, have wasm-bindgen-cli and wasm32-unknown targets preinstalled
# and also have `node` and `yarn` to build JS part of wasm-dpp
FROM rust as builder

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y clang

RUN --mount=type=cache,target=target \
    --mount=type=cache,target=$CARGO_HOME/git \
    --mount=type=cache,target=$CARGO_HOME/registry \
    rustup target add wasm32-unknown-unknown && \
    cargo install -f wasm-bindgen-cli

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - &&\
    apt-get install -y nodejs build-essential &&\
    corepack prepare yarn@stable --activate &&\
    corepack enable
