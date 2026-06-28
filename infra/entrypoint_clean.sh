#!/bin/bash
# Entrypoint for the clean foundation CI image.
#
# Ensures the project-owned docker runtime images expected by
# hara.runtime.basic (foundation-base/rt-basic-<lang>:latest and
# foundation-base/rt-twostep-<lang>:latest) are available in the host docker
# daemon before running the actual command.
#
# The container is started with the host docker socket mounted, so docker
# commands here operate on the CI runner's daemon.  Images are first pulled
# from GHCR (fast path); if that fails they are built from the mounted
# foundation-base repository (fallback).

set -e

# Languages referenced by hara.runtime.basic.docker.registry/+registry+
RT_BASIC_LANGS=(erlang js julia lua perl php python r ruby)

# GHCR source prefix for cached rt-basic images
RT_BASIC_SRC_PREFIX="ghcr.io/zcaudate-xyz/foundation-base/rt-basic"

# Local image name expected by the test suite
RT_BASIC_DST_PREFIX="foundation-base/rt-basic"

ensure_rt_basic_image() {
  local lang=$1
  local dst="${RT_BASIC_DST_PREFIX}-${lang}:latest"
  local src="${RT_BASIC_SRC_PREFIX}-${lang}:latest"

  if docker image inspect "$dst" >/dev/null 2>&1; then
    echo "[rt-basic] ${lang}: local image already present"
    return 0
  fi

  echo "[rt-basic] ${lang}: ensuring local image '${dst}'"

  # Fast path: pull the pre-built GHCR image and retag to the local name
  # expected by the test suite.
  if docker pull "$src" >/dev/null 2>&1; then
    docker tag "$src" "$dst"
    echo "[rt-basic] ${lang}: pulled and retagged from ${src}"
    return 0
  fi

  # Fallback: build from the Dockerfile shipped with foundation-base.  The
  # repository is expected to be mounted at the container workdir.
  local dockerfile_dir="./docker/rt.basic/${lang}"
  if [ ! -d "$dockerfile_dir" ]; then
    echo "[rt-basic] ${lang}: ERROR: no Dockerfile at ${dockerfile_dir}" >&2
    return 1
  fi

  echo "[rt-basic] ${lang}: building from ${dockerfile_dir}"
  docker build -t "$dst" "$dockerfile_dir"
  echo "[rt-basic] ${lang}: built locally"
}

for lang in "${RT_BASIC_LANGS[@]}"; do
  ensure_rt_basic_image "$lang"
done

# Two-step compile/run runtime images used by hara.runtime.basic twostep tests.
RT_TWOSTEP_LANGS=(c haskell lean ocaml rust)
RT_TWOSTEP_SRC_PREFIX="ghcr.io/zcaudate-xyz/foundation-base/rt-twostep"
RT_TWOSTEP_DST_PREFIX="foundation-base/rt-twostep"

ensure_rt_twostep_image() {
  local lang=$1
  local dst="${RT_TWOSTEP_DST_PREFIX}-${lang}:latest"
  local src="${RT_TWOSTEP_SRC_PREFIX}-${lang}:latest"

  if docker image inspect "$dst" >/dev/null 2>&1; then
    echo "[rt-twostep] ${lang}: local image already present"
    return 0
  fi

  echo "[rt-twostep] ${lang}: ensuring local image '${dst}'"

  if docker pull "$src" >/dev/null 2>&1; then
    docker tag "$src" "$dst"
    echo "[rt-twostep] ${lang}: pulled and retagged from ${src}"
    return 0
  fi

  local dockerfile_dir="./docker/rt.twostep/${lang}"
  if [ ! -d "$dockerfile_dir" ]; then
    echo "[rt-twostep] ${lang}: ERROR: no Dockerfile at ${dockerfile_dir}" >&2
    return 1
  fi

  echo "[rt-twostep] ${lang}: building from ${dockerfile_dir}"
  docker build -t "$dst" "$dockerfile_dir"
  echo "[rt-twostep] ${lang}: built locally"
}

for lang in "${RT_TWOSTEP_LANGS[@]}"; do
  ensure_rt_twostep_image "$lang"
done

# Hand off to the command supplied to the container.
exec "$@"
