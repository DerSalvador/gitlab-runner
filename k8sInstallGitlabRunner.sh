#!/bin/bash
shopt -u extglob; set +H
kubectx gke_plucky-door-200208_europe-west2-b_gitlab-runner
kubectl create namespace gitlab-runner
cd $(dirname $0)
cd chart 

# k8sGrantClusterAdminForServiceAccountOfUser.sh gitlab-runner gitlab-runner:default default
# k8sGrantClusterAdminForServiceAccountOfUser.sh default default default

helm repo add gitlab https://charts.gitlab.io
echo Once you have configured GitLab Runner in your values.yml file, run the following:
helm ls 

mkdir -p tmp
TMPF_APPLY=tmp/$(basename $(mktemp tmp.apply.XXXXX))
rm -f $(basename $TMPF_APPLY)
TMPF_TEMPLATE=gitlab-runner.helm.rendered.template
TMPF_KUST=tmp/$(basename $(mktemp tmp.kust.XXXXXX))
rm -f $(basename $TMPF_KUST)
[ ! -f kustomization.yaml ] && echo "No kustomization.yaml found, creating default one" && touch kustomization.yaml
if ! grep -i resources kustomization.yaml; then
        cp kustomization.yaml $TMPF_KUST
        echo "resources:" > kustomization.yaml
        echo "  - $TMPF_TEMPLATE" >> kustomization.yaml
        cat $TMPF_KUST >>  kustomization.yaml
        echo Using following kustomization.yaml
        cat kustomization.yaml
fi
kubectl create namespace gitlab-runner
kubens gitlab-runner 
helm template --namespace gitlab-runner --set gitlabUrl=https://gitlab.com/ --set runnerRegistrationToken=zDWxeYg52sR81zy1-2Zf  -f ../values.yaml  gitlab-runner > $TMPF_TEMPLATE
sed -i -e "s/RELEASE-NAME/brokerme/g" $TMPF_TEMPLATE
sed -i -e "s/192.168.99.100/$(gcloudGetIngressIP.sh brokerme)/g" $TMPF_TEMPLATE
sed -i -e "s/extensions\/v1beta1/apps\/v1/g" $TMPF_TEMPLATE
kustomize build . > $TMPF_APPLY
kustomize build .
read -p "Apply kustomized helm template? (y/n): " yn
if [ "$yn" == "y" ]; then
  # kubectl apply -n gitlab-runner -f dotnet-repo-pvc.yaml
  kubectl apply -n gitlab-runner -f $TMPF_APPLY
  k8sWaitSomeSecondsForPods.sh
fi
k8sGrantClusterAdminForServiceAccountOfUser.sh gitlab-runner system:serviceaccount:gitlab-runner:default default

