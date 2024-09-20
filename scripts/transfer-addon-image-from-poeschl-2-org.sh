#!/usr/bin/env bash
set -e

# Example call
# ./transfer-addon-image-from-poeschl-2-org.sh
# Enter the image name (without architecture and version and ha- prefex): asterisk
# Enter the architectures (separated by spaces): i386 amd64 aarch64 armhf armv7
# Enter the versions (separated by spaces): 1.0.0 1.1.0 1.1.1

read -p "Enter the image name (without architecture and version and ha- prefix): " IMAGE_NAME
read -p "Enter the architectures (separated by spaces): " ARCHITECTURES
read -p "Enter the versions (separated by spaces): " VERSIONS

DRY_RUN=0

if [[ -z "$ARCHITECTURES" || -z "$VERSIONS" ]]; then
  echo "Architectures or versions not specified."
  exit 1
fi

IMAGES_TO_REMOVE=()

for VERSION in $VERSIONS; do
  for ARCH in $ARCHITECTURES; do
    OLD_IMAGE="ghcr.io/poeschl/ha-${IMAGE_NAME}-${ARCH}:${VERSION}"
    NEW_IMAGE="ghcr.io/poeschl-homeassistant-addons/${IMAGE_NAME}-${ARCH}:${VERSION}"

    echo "Transferring $OLD_IMAGE -> $NEW_IMAGE"

    if [ "$DRY_RUN" = "0" ]; then
      if podman pull "$OLD_IMAGE"; then
        podman tag "$OLD_IMAGE" "$NEW_IMAGE"
        podman push "$NEW_IMAGE"
        IMAGES_TO_REMOVE+=("$OLD_IMAGE" "$NEW_IMAGE")
      else
        echo "Skipping $OLD_IMAGE (not found)."
      fi
    else
      echo "!!! Dry run !!!"
    fi
  done
done

# Remove all images at the end
if [ "$DRY_RUN" = "0" ]; then
  echo "Removing images: ${IMAGES_TO_REMOVE[*]}"
  podman rmi "${IMAGES_TO_REMOVE[@]}"
fi
