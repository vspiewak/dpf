#!/usr/bin/env bash

CONTAINER_NAME=$1
FORWARD_PORT=$2
CONTAINER_PORT=$3

if ! [ -x "$(command -v jq)" ]; then
  echo "Error: jq is not installed." >&2
  exit 1
fi

if [ "$#" -lt 2 ]; then
  echo "Usage: ${0} container_name port_to_forward container_port" >&2
  exit 2
fi

if [ "$#" -eq 2 ]; then
  CONTAINER_PORT=$2
fi

if ! [[ "${FORWARD_PORT}" =~ ^[0-9]+$ ]]; then
  echo "Error: invalid port to forward" >&2
  exit 3
fi

if ! [[ "${CONTAINER_PORT}" =~ ^[0-9]+$ ]]; then
  echo "Error: invalid container port" >&2
  exit 4
fi

if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
  echo "Error: container ${CONTAINER_NAME} doesn't exist !" >&2
  exit 5
fi

if ! $(docker inspect ${CONTAINER_NAME} | jq -r '.[] | .State.Running'); then
  echo "Error: container ${CONTAINER_NAME} not running !" >&2
  exit 6
fi

if ! $(docker inspect cvaden-users-db | jq -r '.[] | .NetworkSettings.Ports | has("'"${CONTAINER_PORT}"'/tcp")'); then
  echo "Error: container ${CONTAINER_NAME} doesn't interact with port ${CONTAINER_PORT} !" >&2
  exit 7
fi

if $(nc 127.0.0.1 ${FORWARD_PORT} < /dev/null); then
  echo "Error: port ${FORWARD_PORT} already in use" >&2
  exit 8
fi

NETWORK_NAME=$(docker inspect ${CONTAINER_NAME} | jq -r '.[] | .HostConfig.NetworkMode')

echo "forwarding localhost:${FORWARD_PORT} to ${CONTAINER_NAME}:${CONTAINER_PORT} ..."

docker run \
  -it --rm \
  --net=${NETWORK_NAME} \
  --link=${CONTAINER_NAME} \
  -p ${FORWARD_PORT}:${CONTAINER_PORT} \
  --name=${CONTAINER_NAME}_port_forward \
  alpine/socat \
  TCP4-LISTEN:${CONTAINER_PORT},fork,reuseaddr TCP4:${CONTAINER_NAME}:${CONTAINER_PORT}
