Example Deployment
-----------------
This is just a simple example deployment for creating a Kubernetes Deployment on a Datica managed K8s cluster. We recommend using this as a baseline to expand off, as it is the most compliant deployment possible (using raw Load Balancers is NOT a good idea). Ingress is only needed if you want to make the service publically available. Any value in curl brackets is something you should replace, not something that Kubernetes understands.

To create the deployment simply run:
```sh
kubectl create -f ./deployment.yaml
kubeclt create -f ./service.yaml
kubectl create -f ./ingress.yaml
```