#!/usr/bin/env bash
set -e

TARGET_REGISTRY=$1
SOURCE_IMAGES=(${*: 2})
DRY_RUN=1

if [[ -z "$SOURCE_IMAGES" ]]; then
  echo 'No source image specified. Needs to be written as "transfer-addon-image-2-registry.sh <target-registry> <source-images> <source-image> ..."'
  echo 'Example: ./transfer-addon-image-2-registry.sh ghcr.io/poeschl-homeassistant-addons ghcr.io/poeschl/ha-icantbelieveitsnotvaletudo-amd64:4.0.0'
  echo 'You need to be login-ed to the registries already!'
  exit 1
fi

for image in "${SOURCE_IMAGES[@]}"
do
  IMAGE_WITHOUT_REGISTRY=$( cut -d '/' -f 3- <<< "$image" )
  IMAGE_WITHOUT_REGISTRY=${IMAGE_WITHOUT_REGISTRY#'ha-'}
  IMAGE_WITH_NEW_REGISTRY="${TARGET_REGISTRY}/${IMAGE_WITHOUT_REGISTRY}"

  echo "Transfer $image -> $IMAGE_WITH_NEW_REGISTRY"

  if [ "$DRY_RUN" = "0" ]; then
    podman pull "$image"
    podman tag "$image" "$IMAGE_WITH_NEW_REGISTRY"
    podman push "$IMAGE_WITH_NEW_REGISTRY"

    podman rmi "$image" "$IMAGE_WITH_NEW_REGISTRY"
  else
    echo "!!! Dry run !!!"
  fi
done
