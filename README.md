# infra-testing

This creates the docker image `ghcr.io/zcaudate-xyz/infra-foundation:main` for testing of all the `foundation` libraries:
  - foundation-base
  - foundation-embed
  - foundation-fx
  - foundation-web

### Docker Container

The image can be created by pulling down the container from `ghcr.io`:

```bash
docker pull ghcr.io/zcaudate-xyz/infra-foundation:main
```

### Local Compilation

The image can be created by:

```bash
git clone git@github.com:zcaudate-xyz/infra-testing.git
cd infra-testing
docker build . -f infra/Dockerfile_foundation -t ghcr.io/zcaudate-xyz/infra-foundation:main
```
