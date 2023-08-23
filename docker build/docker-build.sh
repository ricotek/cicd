#!/usr/bin/env bash
cd $DOCKERFILE_PATH
docker build -f Dockerfile -t "$COMPONENT_FULLNAME" ..
docker save --output tmp-image.docker $COMPONENT_FULLNAME
docker load --input ./tmp-image.docker
docker images REPOSITORY_PRIVATE="docker/$ECR_NAME"