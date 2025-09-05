#!/bin/sh

set -x

export PATH=/usr/sbin:/sbin:/usr/bin:/bin

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export LANGUAGE=C.UTF-8

cat > /usr/sbin/policy-rc.d << EOF
#!/bin/sh
echo "All runlevel operations denied by policy" >&2
exit 101
EOF

chmod a+x /usr/sbin/policy-rc.d

# use official saltstack (contains newer version)
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources

apt-get -y update
apt-get -y install salt-minion busybox-static

rm /usr/sbin/policy-rc.d

systemctl enable rc-runonce
systemctl disable salt-minion
systemctl disable userconfig

rm -f /etc/ssh/*key*
rm -f /etc/ssh/moduli

rm /bootstrap.sh
