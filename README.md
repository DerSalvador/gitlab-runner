# gitlab-runner

Helm Chart for deploying Gitlab Runner on Kubernetes Clusters

helm repo add gitlab https://charts.gitlab.io
helm init

Once you have configured GitLab Runner in your values.yml file, run the following:

helm install --namespace <NAMESPACE> --name gitlab-runner -f <CONFIG_VALUES_FILE> gitlab/gitlab-runner

Where:

<NAMESPACE> is the Kubernetes namespace where you want to install the GitLab Runner.
<CONFIG_VALUES_FILE> is the path to values file containing your custom configuration. See the Configuring GitLab Runner using the Helm Chart section to create it.
Updating GitLab Runner using the Helm Chart
Once your GitLab Runner Chart is installed, configuration changes and chart updates should be done using helm upgrade:

helm upgrade --namespace <NAMESPACE> -f <CONFIG_VALUES_FILE> <RELEASE-NAME> gitlab/gitlab-runner

