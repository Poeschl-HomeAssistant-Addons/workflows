#!/usr/bin/env bash
set -e

# Example call
# ./transfer-addon-image-from-poeschl-2-org.sh
# Enter the target registry: ghcr.io/poeschl-homeassistant-addons
# Enter the image name (without architecture and version): ha-asterisk
# Enter the architectures (separated by spaces): i386 amd64 aarch64 armhf armv7
# Enter the versions (separated by spaces): 1.0.0 1.1.0 1.1.1

# Prompt user for input
read -p "Enter the target registry: " TARGET_REGISTRY
read -p "Enter the image name (without architecture and version): " IMAGE_NAME
read -p "Enter the architectures (separated by spaces): " ARCHITECTURES
read -p "Enter the versions (separated by spaces): " VERSIONS

DRY_RUN=0

# Check if architectures or versions are missing
if [[ -z "$ARCHITECTURES" || -z "$VERSIONS" ]]; then
  echo "Architectures or versions not specified."
  exit 1
fi

# Iterate over architectures and versions
for ARCH in $ARCHITECTURES; do
  for VERSION in $VERSIONS; do
    IMAGE="ghcr.io/poeschl/${IMAGE_NAME}-${ARCH}:${VERSION}"
    IMAGE_WITHOUT_REGISTRY=$( cut -d '/' -f 3- <<< "$IMAGE" )
    IMAGE_WITH_NEW_REGISTRY="${TARGET_REGISTRY}/${IMAGE_WITHOUT_REGISTRY}"

    echo "Transferring $IMAGE -> $IMAGE_WITH_NEW_REGISTRY"

    if [ "$DRY_RUN" = "0" ]; then
      if podman pull "$IMAGE"; then
        podman tag "$IMAGE" "$IMAGE_WITH_NEW_REGISTRY"
        podman push "$IMAGE_WITH_NEW_REGISTRY"
        podman rmi "$IMAGE" "$IMAGE_WITH_NEW_REGISTRY"
      else
        echo "Skipping $IMAGE (not found)."
      fi
    else
      echo "!!! Dry run !!!"
    fi
  done
done
