#!/bin/bash
shopt -u extglob; set +H
. bashrc_alias 2>&1 >/dev/null
loginToDockerhubAsBrokerme.sh
docker build container/ -t docker.io/brokerme/gitlab-runner-root:alpine-v11.6.0
docker tag docker.io/brokerme/gitlab-runner-root:alpine-v11.6.0 docker.io/brokerme/gitlab-runner-root:latest
docker push docker.io/brokerme/gitlab-runner-root:alpine-v11.6.0
docker push docker.io/brokerme/gitlab-runner-root:latest
