ARG PYTHON_IMAGE=python:3.13-slim@sha256:d98cc29d3266e535dd9da1099688d9cb3ca4753813571e071763d17725460962
ARG RUST_IMAGE=rust:1.98-slim@sha256:4cd829461bd5c4d511c32e269da9cb8929223b666519d8004e35fc8d1d771ab7
ARG UV_IMAGE=ghcr.io/astral-sh/uv:0.11.7@sha256:240fb85ab0f263ef12f492d8476aa3a2e4e1e333f7d67fbdd923d00a506a516a
FROM ${RUST_IMAGE} AS rust
FROM ${UV_IMAGE} AS uv
FROM ${PYTHON_IMAGE} AS builder
COPY --from=rust /usr/local/cargo /usr/local/cargo
COPY --from=rust /usr/local/rustup /usr/local/rustup
COPY --from=uv /uv /usr/local/bin/uv
ENV PATH=/usr/local/cargo/bin:$PATH RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo CARGO_PROFILE_RELEASE_LTO=thin CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16
RUN apt-get update && apt-get install -y --no-install-recommends gcc libc6-dev pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY pyproject.toml uv.lock README.md LICENSE rust-toolchain.toml ./
COPY litellm-rust ./litellm-rust
COPY litellm ./litellm
COPY .cargo ./.cargo
RUN rm litellm/proxy/enterprise && python -c "from pathlib import Path; assert all(p.exists() for p in Path('litellm').rglob('*') if p.is_symlink())"
RUN --mount=type=cache,id=envloop-litellm-1.106.3-target,target=/src/litellm-rust/target uv build --wheel --out-dir /wheels --exclude-newer-package maturin=2026-10-25T23:59:59Z
COPY packaging/envloop ./packaging/envloop
RUN uv venv /opt/envloop-proxyhub && uv pip install --python /opt/envloop-proxyhub/bin/python --require-hashes -r packaging/envloop/requirements.txt && uv pip install --python /opt/envloop-proxyhub/bin/python --no-deps /wheels/*.whl
FROM ${PYTHON_IMAGE}
ARG SOURCE_REVISION
ARG RELEASE_TAG=v1.106.3-envloop.1
LABEL org.opencontainers.image.source=https://github.com/EnvLoop/litellm-proxyhub org.opencontainers.image.revision=${SOURCE_REVISION} org.opencontainers.image.version=${RELEASE_TAG} org.opencontainers.image.licenses=MIT
COPY --from=builder /opt/envloop-proxyhub /opt/envloop-proxyhub
COPY LICENSE /opt/envloop-proxyhub/LICENSE
COPY packaging/envloop/source.json /opt/envloop-proxyhub/source.json
ENV PATH=/opt/envloop-proxyhub/bin:$PATH LITELLM_LOCAL_MODEL_COST_MAP=True DO_NOT_TRACK=1
ENTRYPOINT ["/opt/envloop-proxyhub/bin/python"]
CMD ["-c", "import importlib.metadata, litellm, fastapi, uvicorn; print(importlib.metadata.version('litellm'))"]
