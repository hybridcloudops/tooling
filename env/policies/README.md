# Policies

Contains Kubernetes cloud policies that are getting deployed by the bsc-deployer. They are stored in a dedicated directory because they have to be applied before the apps.

Cloud policies are an artifact of this thesis and are extending the Kubernetes API through a [custom resource definition](policy-crd.yaml).