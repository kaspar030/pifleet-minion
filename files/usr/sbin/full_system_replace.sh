#!/bin/sh

IMAGE="/newimage.gz"

test -f "${IMAGE}" || {
	echo "file \"${IMAGE}\" not found, exiting."
	exit 1
}

ldd /bin/busybox 2>&1 | grep -q "not a dynamic executable" || {
	echo "this script requires busybox to be statically linked."
	echo "install \"busybox-static\"."
	exit 1
}

echo "Full system upgrade. This will WIPE the running system and overwrite the"
echo "SD card with the contents of ${IMAGE}!"
echo ""
echo "Press return to continue, or CTRL-C to abort"

read __UNUSED

echo "You've been warned. Continuing"

set -e

ln -f /bin/busybox /sbin/init

echo "::restart:/sbin/init" > /etc/inittab
echo "::sysinit:/sbin/updater_init.sh" >> /etc/inittab

reboot
