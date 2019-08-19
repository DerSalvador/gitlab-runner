#!/bin/bash
shopt -u extglob; set +H
kubectl config get-contexts
echo "Current k8s context $(kubectl config current-context)"
read -p "Want to add gitlab runner to current kubernetes cluster (y/n)? " yesno
if [ "$yesno" == "y" ]; then
	kubectl create namespace gitlab-runner
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system michael.roepke@filekeys.com tiller
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system kube-system:default tiller
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system default tiller
	./k8sGrantClusterAdminForServiceAccountOfUser.sh gitlab-runner gitlab-runner:default default
	helm repo add gitlab https://charts.gitlab.io
	helm init --service-account tiller 
	helm ls
    helm upgrade --namespace gitlab-runner -f ./values.yaml gitlab-runner gitlab/gitlab-runner
else
	echo "No Joy"
fi

