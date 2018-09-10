Example Deployment
-----------------
This is just a simple example deployment for creating a Kubernetes Deployment on a Datica managed K8s cluster. We recommend using this as a baseline to expand off, as it is the most compliant deployment possible (using raw Load Balancers is NOT a good idea). Ingress is only needed if you want to make the service publicly available. Any value in braces is something you should replace, not something that Kubernetes understands.

The ingress host_name should either be a DNS CNAME record pointing to the ingress-controller loadbalancer address, or the loadbalancer address itself for testing. The ingress-controller address can be found under the EXTERNAL-IP section in the output of the following command:
```sh
kubectl -n ingress-nginx get svc/ingress-nginx -o wide
```

The template.sh script can be used to generate valid kubernetes YAML off of the provided templates. The new YAML files will be located at ./{{deployment_name}}/

Use the following command to generate self-signed certificates for development purposes:
```sh
openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365
```

To create the deployment simply run:
```sh
kubectl -n {{deployment_namespace}} create secret tls {{deployment_name}}-tls --cert=path/to/cert.pem --key=path/to/key.pem
kubectl create -f ./deployment.yaml
kubeclt create -f ./service.yaml
kubectl create -f ./ingress.yaml
```

If everything is wired up correctly, you should be able to hit your deployment with:
```sh
curl -k https://{{host_name}}
```

NOTE: If you are using self-signed certificates, or certificates signed by a non-public CA, your browser will consider the connection to be insecure, however it will still be encrypted. In order for your browser to recognize your certificates, you will need to use a public certificate authority, such as Let's Encrypt, to create your certificates. For development purposes, it is ok to use self-signed certs and ignore the browser warning.