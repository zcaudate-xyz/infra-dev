# infra-dev

This creates the docker images `ghcr.io/zcaudate-xyz/infra-foundation-clean` and `ghcr.io/zcaudate-xyz/infra-foundation-dev` for testing of all the `foundation` libraries:
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
docker pull ghcr.io/zcaudate-xyz/infra-foundation-dev:main
```

### Local Compilation

The image can be created by:

```bash
git clone git@github.com:zcaudate-xyz/infra-dev.git
cd infra-foundation
docker build . -f infra/Dockerfile_foundation_clean -t ghcr.io/zcaudate-xyz/infra-foundation-clean:main
```
