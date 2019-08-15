#!/bin/bash
set -eo pipefail

# Generates kubernetes YAML files off of the templates included in this project

usage() {
  echo -e "\nUsage: ./template.sh -d mydeployment -n default -i myimage:v2 -p 1234 --hostname my.cname.record
    Flags:
      Required:
        -d, --deployment: Deployment name
        -n, --namespace: Deployment namespace
        -i, --image: Deployment image
        -p, --port: Port to use for the kuberenetes service
        --hostname: Hostname to use for ingress
      Optional:
        -c, --container-port: Port that the container is listening on (default: 80)
        --port-name: Name of the port (default: http)
        -h, --help: Print usage"

  exit ${1:-0}
}

CONTAINER_PORT=80
PORT_NAME=http
while [ "$1" ]; do
  case $1 in
    -d | --deployment )
                            shift
                            DEPLOYMENT_NAME=$1
                            ;;
    -n | --namespace )
                            shift
                            NAMESPACE=$1
                            ;;
    -i | --image )
                            shift
                            IMAGE=$1
                            ;;
    -p | --port )
                            shift
                            PORT=$1
                            ;;
    -c | --container-port )
                            shift
                            CONTAINER_PORT=$1
                            ;;
    --port-name )
                            shift
                            PORT_NAME=$1
                            ;;
    --hostname )
                            shift
                            INGRESS_HOSTNAME=$1
                            ;;
    -h | --help )
                            usage
                            ;;
    * )
                            echo "Error: \"$1\" is not a valid option"
                            usage 1
                            ;;
  esac
  shift
done

if [ ! "$DEPLOYMENT_NAME" ] || [ ! "$NAMESPACE" ] || [ ! "$IMAGE" ] || [ ! "$PORT" ] || [ ! "$INGRESS_HOSTNAME" ]; then
  echo "Error: Missing required arguments"
  usage 1
fi

template() {
  cat $1 | \
    sed s,{{deployment_name}},"$DEPLOYMENT_NAME",g | \
    sed s,{{deployment_namespace}},"$NAMESPACE",g | \
    sed s,{{deployment_image}},"$IMAGE",g | \
    sed s,{{service_port}},"$PORT",g | \
    sed s,{{container_port}},"$CONTAINER_PORT",g | \
    sed s,{{port_name}},"$PORT_NAME",g | \
    sed s,{{host_name}},"$INGRESS_HOSTNAME",g
}

mkdir ${DEPLOYMENT_NAME} &>/dev/null || true 
DIRNAME=$(dirname $0)
template ${DIRNAME}/templates/deployment.yaml > ${DEPLOYMENT_NAME}/deployment.yaml
template ${DIRNAME}/templates/service.yaml > ${DEPLOYMENT_NAME}/service.yaml
template ${DIRNAME}/templates/ingress.yaml > ${DEPLOYMENT_NAME}/ingress.yaml

echo -e "K8s yaml created:\n  ${DEPLOYMENT_NAME}/deployment.yaml\n  ${DEPLOYMENT_NAME}/service.yaml\n  ${DEPLOYMENT_NAME}/ingress.yaml"