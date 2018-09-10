Example Deployment
-----------------
This is a simple example deployment for creating a deployment on a Datica [Compliant Kubernetes Service](https://datica.com/compliant-kubernetes-service/) cluster. We recommend using this as a baseline to expand off of to use [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) configurations instead of loadbalancer services.

Any value in braces is something you should replace, not something that Kubernetes understands.

The ingress `host_name` should either be a DNS CNAME record pointing to the ingress-controller loadbalancer address, or the loadbalancer address itself for testing. The ingress-controller address can be found under the `EXTERNAL-IP` section in the output of the following command:
```sh
kubectl -n ingress-nginx get svc/ingress-nginx -o wide
```

The template.sh script can be used to generate valid kubernetes YAML off of the provided templates. The new YAML files will be located at ./{{deployment_name}}/
```sh
./template.sh --deployment hello --namespace default --image nginxdemos/hello --port 1234 --hostname my.cname.com
```

Use the following command to generate self-signed certificates for development:
```sh
openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365
```

To create the deployment, run:
```sh
kubectl -n {{deployment_namespace}} create secret tls {{deployment_name}}-tls --cert=path/to/cert.pem --key=path/to/key.pem
cd ./{{deployment_name}}
kubectl apply -f ./deployment.yaml
kubeclt apply -f ./service.yaml
kubectl apply -f ./ingress.yaml
```

You should be able to reach your deployment with:
```sh
curl -k https://{{host_name}}
```

NOTE: If you are using self-signed certificates, or certificates signed by a non-public CA, your browser will consider the connection to be insecure, however it will still be encrypted. In order for your browser to recognize your certificates, you will need to use a public certificate authority, such as [Let's Encrypt](https://letsencrypt.org/), to create your certificates. For development purposes, it is ok to use self-signed certs and ignore the browser warning.
