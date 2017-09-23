## jabujabu
Deploying concourse to [Google Container Engine](https://cloud.google.com/container-engine/)

Get tools:
```
$ brew cask install google-cloud-sdk
$ brew install kubernetes-helm kubernetes-cli
```

Create a container cluster:
```
$ gcloud container clusters create concourse
```

Authenticate `kubectl` with your cluster:
```
$ gcloud auth application-default login
```

Install the Tiller server on your cluster:
```
$ helm init
```

Install the [concourse helm chart](https://github.com/kubernetes/charts/tree/master/stable/concourse):
```
$ helm install --name concourse stable/concourse
```

Create a load balancer that exposes the deployment:
```
$ kubectl expose deployment concourse-web --type=LoadBalancer --name=concourse-load-balancer
```

Get the `EXTERNAL-IP` of the load balancer:
```
$ kubectl get service concourse-load-balancer
```

Navigate to the ATC UI at: `http://<EXTERNAL-IP>:8080`