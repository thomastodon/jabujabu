## jabujabu
Deploying concourse to [Google Container Engine](https://cloud.google.com/container-engine/)

Get tools:
```
$ brew cask install google-cloud-sdk
$ brew install kubernetes-helm kubernetes-cli certbot
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

Generate a cert [manually](https://certbot.eff.org/docs/using.html#manual):
```
$ sudo certbot certonly --manual --preferred-challenges dns -d jabujabu.tk
```

Create a secret from that cert:
```
$ kubectl create secret tls concourse-web-tls --cert=/etc/letsencrypt/live/jabujabu.tk/cert.pem --key=/etc/letsencrypt/live/jabujabu.tk/privkey.pem
```

Install the [concourse helm chart](https://github.com/kubernetes/charts/tree/master/stable/concourse):
```
$ helm install --name concourse -f values.yml stable/concourse
```

Get the `EXTERNAL-IP` of the load balancer:
```
$ kubectl get ingress concourse-web
```

Update the value of DNS entry for jabujabu.tk to `<EXTERNAL-IP>`

Navigate to the ATC UI at: https://jabujabu.tk