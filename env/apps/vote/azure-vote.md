# azure-vote

Vote service with front and backend components. For more information check out the Azure docs [kubernetes walkthrough](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough).

After deploy run
```
kubectl get service azure-vote-front
```
Output:
```
NAME               TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
azure-vote-front   LoadBalancer   10.0.37.27   52.179.23.131     80:30572/TCP   6s
```

Open the external IP in your browser to serve the frontend, e.g. `http://52.179.23.131`