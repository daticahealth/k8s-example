#!/bin/bash
set -eo pipefail

# Generates kubernetes YAML files off of the templates included in this project

usage() {
  echo -e "\nUsage: ./certs.sh --deployment mydeployment --hostname my.cname.record
    Flags:
      Required:
        -d, --deployment: Deployment name 
        --hostname: Hostname to use for ingress
      Optional:
        -h, --help: Print usage"

  exit ${1:-0}
}

while [ "$1" ]; do
  case $1 in
    -d | --deployment )
                            shift
                            DEPLOYMENT_NAME=$1
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

if [ ! "$DEPLOYMENT_NAME" ] || [ ! "$INGRESS_HOSTNAME" ]; then
  echo "Error: Missing required arguments"
  usage 1
fi

# Create self-signed cert pair
mkdir ${DEPLOYMENT_NAME} &>/dev/null || true
OPENSSL_CONF=$(dirname $0)/templates/openssl.conf
cat ${OPENSSL_CONF} | sed "s,{{dns_address}},${INGRESS_HOSTNAME},g; s,{{deployment_name}},${DEPLOYMENT_NAME},g" > ${OPENSSL_CONF}.tmp
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${DEPLOYMENT_NAME}/key.pem -out ${DEPLOYMENT_NAME}/cert.pem -config ${OPENSSL_CONF}.tmp

rm ${OPENSSL_CONF}.tmp