# BSc env metadata repository

Environment metadata repository that contains everything needed for the GitOps workflow. In addition, all infrastructure setups are provided in form of terraform modules.

## Content
```
.               (metadata repository)
├── apps        (K8s app manifests)
├── grafana     (grafana setup and dashboards)
├── infra       (infrastructure setup)
├── namespaces  (K8s namespaces)
└── policies    (K8s CRD policies)

```

## References

References to resources used in this repository:

* [minikube monitoring setup](apps/monitoring): GitHub [bakins/minikube-prometheus-demo][1].
* [azure-vote](apps/vote/azure-vote.yaml): Azure docs [kubernetes walkthrough](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough)


<!-- refs -->
[1]: https://github.com/bakins/minikube-prometheus-demo
[2]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
[3]: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough
