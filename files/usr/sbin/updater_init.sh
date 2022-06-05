#!/bin/busybox sh

IMAGE=/newimage.gz
TMPROOT=/tmp

mount -t proc none /proc
mount -t sysfs none /sys

set -e
set -x
mkdir -p ${TMPROOT}
mount -t tmpfs none ${TMPROOT} -o size=800m
cat << EOF > ${TMPROOT}/updater.sh
#!/bin/sh
set -x

echo 1 > /proc/sys/kernel/sysrq

umount /oldroot

echo "writing image..."
zcat /image.gz > /dev/mmcblk0

echo "syncing..."
sync

echo "rebooting..."
echo b > /proc/sysrq-trigger

EOF

chmod a+x ${TMPROOT}/updater.sh

for i in sbin bin proc sys dev run usr var tmp etc oldroot; do
	mkdir -p ${TMPROOT}/${i}
done

echo "::sysinit:/updater.sh" > ${TMPROOT}/etc/inittab

cp /bin/busybox ${TMPROOT}/bin/busybox

for i in sh ls mount umount gz sync wget tar mdev; do
	ln -s /bin/busybox ${TMPROOT}/bin/$i
done

for i in init; do
	ln -s /bin/busybox ${TMPROOT}/sbin/$i
done

cp ${IMAGE} ${TMPROOT}/image.gz

mount --make-rprivate / # necessary for pivot_root to work
pivot_root ${TMPROOT} ${TMPROOT}/oldroot
for i in dev proc sys; do /bin/mount --move /oldroot/$i /$i; done

chroot . kill -QUIT 1 &
