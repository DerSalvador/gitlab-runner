#!/bin/bash
shopt -u extglob; set +H
# kubectx default/console-sand99-emea-hck8s-me:443/michael.roepke@filekeys.com
# oc login https://console.sand99-emea.hck8s.me:443 --token=B-bKb2nE3GfjSvdqMqyJyj71ITqBB3JOg_mkTOHIla8
kubectx minikube
kubectl create namespace gitlab-runner
cd ~/hc/gitlab-runner/chart 

../k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system michael.roepke@filekeys.com tiller
../k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system kube-system:default tiller
../k8sGrantClusterAdminForServiceAccountOfUser.sh kube-system default tiller
../k8sGrantClusterAdminForServiceAccountOfUser.sh gitlab-runner gitlab-runner:default default
../k8sGrantClusterAdminForServiceAccountOfUser.sh default default default

helm repo add gitlab https://charts.gitlab.io
helm init --service-account tiller 
echo Once you have configured GitLab Runner in your values.yml file, run the following:
helm ls --tiller-namespace default

rm -rf tmp/
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
gitlabUrl=$1  # : https://gitlab.hce.heidelbergcement.com/ 
## The Registration Token for adding new Runners to the GitLab Server. This must
## be retrieved from your GitLab Instance.
## ref: https://docs.gitlab.com/ce/ci/runners/README.html
##
runnerRegistrationToken=$2 #: "yacAHQ72EdrDi1r-czsr"

if [ ! -z "$gitlabUrl" ]; then
   overrideSettings="--set gitlabUrl=$gitlabUrl --set runnerRegistrationToken=$runnerRegistrationToken"
fi

echo helm template --namespace gitlab-runner -f /Users/michaelmellouk/hc/gitlab-runner/values.yaml $overrideSettings gitlab-runner
helm template --namespace gitlab-runner -f /Users/michaelmellouk/hc/gitlab-runner/values.yaml $:overrideSettings gitlab-runner > $TMPF_TEMPLATE
sed -i -e "s/release-name/gitlab-runner/g" $TMPF_TEMPLATE
sed -i -e "s/192.168.99.100/$(minikube ip)/g" $TMPF_TEMPLATE
kustomize build . > $TMPF_APPLY
kustomize build .
read -p "Apply kustomized helm template? (y/n): " yn
if [ "$yn" == "y" ]; then
  kubectl apply -n gitlab-runner -f dotnet-repo-pvc.yaml
  kubectl apply -n gitlab-runner -f $TMPF_APPLY
  k8sWaitSomeSecondsForPods.sh
fi

