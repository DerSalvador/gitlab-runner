#!/bin/bash
usage() {
echo "Usage: $(basename $0) namespace user serviceaccount"
}

[ -z "$3" ] && [ -z "$2" ] && [ ! -z "$1" ] && usage && kubectl get user -n $1 && exit 1
[ -z "$3" ] && [ ! -z "$2" ] && usage && kubectl get sa -n $1 && exit 1
[ -z "$3" ] && usage && kubectl get namespaces && exit 1
kubectl delete clusterrolebinding clusterroles.rbac.authorization.k8s.io.$1.$3.cluster-admin 
kubectl create clusterrolebinding clusterroles.rbac.authorization.k8s.io.$1.$3.cluster-admin --clusterrole=cluster-admin --user=$2 --namespace $1 --serviceaccount $1:$3
