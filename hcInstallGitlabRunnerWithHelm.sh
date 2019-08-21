#!/bin/bash
shopt -u extglob; set +H
kubectl config get-contexts
echo "Current k8s context $(kubectl config current-context)"
read -p "Want to add gitlab runner to current context (y/n)? " yesno
if [ "$yesno" == "y" ]; then
    GR_NS=gitlab-runner-dev
	TILLER_NS=tiller
	TILLER_SA=tiller
	kubectl create namespace $GR_NS
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system michael.roepke@filekeys.com $TILLER_SA
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system kube-system:default $TILLER_SA
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system default $TILLER_SA
	./k8sGrantClusterAdminForServiceAccountOfUser.sh $GR_NS $GR_NS:default default
	helm repo add gitlab https://charts.gitlab.io
	helm init --service-account $TILLER_SA  --tiller-namespace $TILLER_NS
	helm ls --tiller-namespace $TILLER_NS
	helm install --tiller-namespace $TILLER_NS --namespace $GR_NS --name $GR_NS -f ./values.yaml  gitlab/gitlab-runner
else
	echo "No Joy"
fi

