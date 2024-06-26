#!/bin/sh -eux

docker build --progress=plain --tag "ghcr.io/rekgrpth/freenginx.docker:${INPUTS_BRANCH:-debian}" $(env | grep -E '^DOCKER_' | grep -v ' ' | sort -u | sed 's@^@--build-arg @g' | paste -s -d ' ') --file "${INPUTS_DOCKERFILE:-debian.Dockerfile}" . 2>&1 | tee build.log
