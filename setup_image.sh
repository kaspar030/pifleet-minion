#!/bin/sh

str_reverse() {
    echo $* | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'
}

set -x -e

IMAGE=${1}

[ -f "${IMAGE}" ] || {
    echo "$0: cannot access image file \"$IMAGE\""
    exit 1
}

TMPDIR=/tmp/pifleet
BINDMOUNT="dev sys proc dev/pts"

QEMU_ARCH=aarch64

trap cleanup INT QUIT TERM EXIT

setup() {
    # create temporary directory
    mkdir -p $TMPDIR

    # set up loop device
    LOOPDEV=$(losetup -f -P --show $LOOPDEV "$IMAGE")

    # mount looped file
    mount ${LOOPDEV}p2 $TMPDIR

    # bind mount important directories
    for i in $BINDMOUNT; do mount --bind /$i $TMPDIR/$i; done

    # copy over arm binfmt helper
    cp /usr/bin/qemu-${QEMU_ARCH}-static $TMPDIR/usr/bin
}

cleanup() {
    set +e

    # remove binfmt helper
    rm $TMPDIR/usr/bin/qemu-${QEMU_ARCH}-static

    # unmount previously mounted bind mounts
    for i in $(str_reverse $BINDMOUNT); do umount $TMPDIR/$i; done

    # unmount looped file
    umount $TMPDIR

    losetup -d $LOOPDEV
}

setup

cp -av files/* $TMPDIR
chroot $TMPDIR qemu-${QEMU_ARCH}-static /bin/bash /bootstrap.sh

