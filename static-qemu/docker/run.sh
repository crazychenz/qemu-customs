#!/bin/sh
docker run -ti --rm \
  -v $(pwd):/opt/static-qemu \
  -v /opt/playground/old-archives/x-tools:/opt/x-tools \
  crazychenz/build-qemu-ubuntu-22.04 /usr/bin/bash
