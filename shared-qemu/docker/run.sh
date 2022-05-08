#!/bin/sh
docker run -ti --rm \
  -v $(pwd):/opt/shared-qemu \
  crazychenz/build-qemu-ubuntu-22.04 /usr/bin/bash
