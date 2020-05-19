#!/bin/bash
shopt -u extglob; set +H
gcloud container clusters get-credentials gitlab-runner --zone=europe-west2-b

