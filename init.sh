#!/bin/bash

[ -n "$DOCKER_REPO" ] && echo "$DOCKER_PASSWORD" | docker login "$DOCKER_REPO" --username "$DOCKER_USERNAME" --password-stdin

