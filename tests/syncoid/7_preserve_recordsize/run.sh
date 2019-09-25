#!/bin/bash

# test resumable replication where the original snapshot doesn't exist anymore

set -x
set -e

. ../../common/lib.sh

POOL_IMAGE="/tmp/syncoid-test-7.zpool"
MOUNT_TARGET="/tmp/syncoid-test-7.mount"
POOL_SIZE="1000M"
POOL_NAME="syncoid-test-7"

truncate -s "${POOL_SIZE}" "${POOL_IMAGE}"

zpool create -m none -f "${POOL_NAME}" "${POOL_IMAGE}"

function cleanUp {
  zpool export "${POOL_NAME}"
}

# export pool in any case
trap cleanUp EXIT

zfs create "${POOL_NAME}"/src
zfs create -o recordsize=16k "${POOL_NAME}"/src/16
zfs create -o recordsize=32k "${POOL_NAME}"/src/32
zfs create -o recordsize=128k "${POOL_NAME}"/src/128
../../../syncoid --preserve-recordsize --recursive --debug --compress=none "${POOL_NAME}"/src "${POOL_NAME}"/dst

zfs get recordsize -t filesystem -r "${POOL_NAME}"/dst
