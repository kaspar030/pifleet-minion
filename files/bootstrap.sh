#!/bin/sh

set -x

export PATH=/usr/sbin:/sbin:/usr/bin:/bin
export LANG=C

cat > /usr/sbin/policy-rc.d << EOF
#!/bin/sh
echo "All runlevel operations denied by policy" >&2
exit 101
EOF

chmod a+x /usr/sbin/policy-rc.d

apt-get -y update
apt-get -y install salt-minion

rm /usr/sbin/policy-rc.d

systemctl enable rc-runonce
systemctl disable salt-minion

rm -f /etc/ssh/*key*
rm -f /etc/ssh/moduli

rm /bootstrap.sh
