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

wget -O - https://repo.saltstack.com/apt/debian/8/armhf/latest/SALTSTACK-GPG-KEY.pub | apt-key add -

apt-get -y update
apt-get -y install salt-minion

rm /usr/sbin/policy-rc.d

systemctl enable rc.runonce
systemctl enable salt-minion

rm -f /etc/ssh/*key*
rm -f /etc/ssh/moduli

rm /bootstrap.sh
