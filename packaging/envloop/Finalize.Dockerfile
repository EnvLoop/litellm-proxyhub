ARG COMPILED_IMAGE
FROM ${COMPILED_IMAGE}
ARG SOURCE_REVISION
ARG RELEASE_TAG=v1.106.3-envloop.1
COPY packaging/envloop/source.json /opt/envloop-proxyhub/source.json
LABEL org.opencontainers.image.source=https://github.com/EnvLoop/litellm org.opencontainers.image.revision=${SOURCE_REVISION} org.opencontainers.image.version=${RELEASE_TAG} org.envloop.litellm.upstream-revision=4fa8bf1ff5515e2cb98908c62ba84c87ef938620
