#!/usr/bin/env bash
set -e

SOURCE_IMAGE=$1
TARGET_REGISTRY=$2

if [[ -z "$SOURCE_IMAGE" ]]; then
  echo 'No source image specified. Needs to be written as "transfer-addon-image-2-registry.sh <source-image> <target-registry>."'
  echo 'Example: ./transfer-addon-image-2-registry.sh ghcr.io/poeschl/ha-icantbelieveitsnotvaletudo-amd64:4.0.0 ghcr.io/poeschl-homeassistant-addons'
  echo 'You need to be login-ed to the registries already!'
  exit 1
fi

IMAGE_WITHOUT_REGISTRY=$( cut -d '/' -f 2- <<< "$SOURCE_IMAGE" )
IMAGE_WITH_NEW_REGISTRY="${TARGET_REGISTRY}/${IMAGE_WITHOUT_REGISTRY}"

echo "Transfer $SOURCE_IMAGE -> $IMAGE_WITH_NEW_REGISTRY"

podman pull "$SOURCE_IMAGE"
podman tag "$SOURCE_IMAGE" "$IMAGE_WITH_NEW_REGISTRY"
podman push "$IMAGE_WITH_NEW_REGISTRY"

podman rmi "$SOURCE_IMAGE" "$IMAGE_WITH_NEW_REGISTRY"