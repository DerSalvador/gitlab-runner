#!/bin/bash
shopt -u extglob; set +H

grantClusterAdminRole() {
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system michael.roepke@filekeys.com tiller
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system kube-system:default tiller
	./k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system default tiller
	./k8sGrantClusterAdminForServiceAccountOfUser.sh gitlab-runner gitlab-runner:default default
	./k8sGrantClusterAdminForServiceAccountOfUser.sh gitlab-runner tiller:tiller tiller
	./k8sGrantClusterAdminForServiceAccountOfUser.sh tiller tiller:tiller tiller
    
}

install_tiller() {
    SERVICE_ACCOUNT=tiller
    KUBE_CONTEXT=minikube
    TILLER_NAMESPACE=tiller
    kubectl create namespace $TILLER_NAMESPACE
    kubectl -n $TILLER_NAMESPACE create sa $SERVICE_ACCOUNT

    HELM_OPTS="--tiller-namespace $TILLER_NAMESPACE --kube-context $KUBE_CONTEXT"
    helm reset --force --remove-helm-home --tiller-connection-timeout 10 $HELM_OPTS
    echo "Checking Tiller..."
    echo helm init --upgrade --service-account $SERVICE_ACCOUNT  $HELM_OPTS
    helm init --upgrade --service-account $SERVICE_ACCOUNT  $HELM_OPTS
    echo kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    kubectl rollout status -w "deployment/tiller-deploy" -n $TILLER_NAMESPACE --context=$KUBE_CONTEXT
}

kubectl config get-contexts
echo "Current k8s context $(kubectl config current-context)"
read -p "Want to apply kustomization to gitlab runner to current kubernetes cluster (y/n)? " yesno
if [ "$yesno" == "y" ]; then
	kubectl create namespace gitlab-runner
    grantClusterAdminRole
    mkdir chart
    cd chart
	helm repo add gitlab https://charts.gitlab.io
	helm init --service-account tiller 
	helm ls --tiller-namespace tiller
    if [ $? != 0 ]; then
       read -p "Install Tiller? (y/n): " yesno
       [ "$yesno" == "y" ] && install_tiller
       helm ls --tiller-namespace tiller
    fi
    echo helm fetch gitlab/gitlab-runner
    helm fetch gitlab/gitlab-runner
else
	echo "No Joy"
fi

