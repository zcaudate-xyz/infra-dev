# infra-foundation

This creates the docker image `ghcr.io/zcaudate-xyz/infra-foundation` for testing of all the `foundation` libraries:
  - foundation-base
  - foundation-embed
  - foundation-fx
  - foundation-web

### Docker Container

The image can be created by pulling down the container from `ghcr.io`:

```bash
docker pull ghcr.io/zcaudate-xyz/infra-foundation-clean:main
```

The image with all the code installed is here:

```bash
docker pull ghcr.io/zcaudate-xyz/infra-foundation:main
```

### Local Compilation

The image can be created by:

```bash
git clone git@github.com:zcaudate-xyz/infra-foundation.git
cd infra-foundation
docker build . -f infra/Dockerfile_foundation -t ghcr.io/zcaudate-xyz/infra-foundation-clean:main
```
