# Sandbox LiteLLM runtime

This distribution pins upstream `v1.106.3` at
`4fa8bf1ff5515e2cb98908c62ba84c87ef938620`. The maintenance branch is
`envloop-v1.106.3`, and the first immutable release tag is
`v1.106.3-envloop.1`. Existing main and upstream tags remain unchanged.

The package contains the source-built LiteLLM SDK, its native Rust bridge, FastAPI, Uvicorn
and the release-locked orjson/soundfile dependency closure required by native stream
logging imports. EnvPlatform uploads its per-Trial HTTP facade and configuration at
runtime. No Enterprise extras or separate Admin UI/database service are enabled. The SDK
wheel retains its regular bundled assets. No provider keys or runtime tokens are
installed into this package. MIT licensing remains in `/opt/envloop-proxyhub/LICENSE`.

`requirements.txt` is a hash-pinned subset of upstream `uv.lock`: the SDK plus
FastAPI/Uvicorn/orjson/soundfile and their dependency closure. `sdk-requirements.txt` is the upstream
SDK export; `requirements.in` documents the additional runtime roots. Package
versions are inherited from the release lock. Base Python, Rust and uv images are
pinned by registry digest in the Dockerfile. The build backend remains upstream's
exact `maturin==1.15.0`; its explicit timestamp exception permits that required
backend without changing application dependency versions.

Build locally for the sandbox architecture, then verify imports before publishing:

```bash
docker build --platform linux/amd64 -f packaging/envloop/Dockerfile \
  --build-arg SOURCE_REVISION=FULL_SOURCE_COMMIT \
  -t ghcr.io/envloop/litellm-proxyhub:v1.106.3-envloop.1 .
docker run --rm ghcr.io/envloop/litellm-proxyhub:v1.106.3-envloop.1
```

Publish only after checking source and the native Anthropic facade against a local
synthetic upstream. Read back the registry digest, architecture, OCI source,
revision and version; record package visibility separately. Do not move an existing
release tag or reuse a package tag for different source.

This is a runtime dependency package, not an EnvLoop product revision or a deployed
proxy service. It does not install itself into an existing E2B template. A sandbox
image must provide the compatible interpreter/libraries and the runtime path;
copying the venv alone into an arbitrary older image is not supported. Enabling
`EP_PROXYHUB_ENABLED` without a compatible preinstalled runtime fails closed.

Real E2B/model calls, production configuration activation and environment deployment
are separate operations. The local synthetic test does not establish production
network isolation, billing trust or resource cleanup.

When only source metadata changes after the native build, `Finalize.Dockerfile`
can apply the reviewed source manifest and final OCI revision to the already tested
local compiled image. Verify that image's upstream source and image ID first;
this step never substitutes different compiled code. Record both build commands
and the final registry digest in the release notes.

The release build uses thin LTO and 16 codegen units to bound linking overhead.
Native compilation is cached across packaging retries. The upstream-excluded
`litellm/proxy/enterprise` symlink is removed in the SDK-only build context before
wheel traversal; Enterprise source is not imported to satisfy that link. A symlink
preflight runs before compilation. Runtime capacity/performance still requires
sandbox validation.

The fork defers importing the full proxy request processor until streaming cost
injection is enabled. Native SDK streaming uses the existing passthrough path
without loading proxy budget/database services; proxy cost injection retains the
same processor when enabled. The SDK-only module import is checked in the image
build, and nonstream/SSE/failure/drain are verified against a synthetic upstream
before publication.
