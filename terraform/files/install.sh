mkdir /volume
mount /dev/xvdh /volume || mkfs -t ext4 /dev/xvdh
echo '/dev/xvdh /volume ext4 defaults,nofail 0 2' >> /etc/fstab
mount -a

yum -y -q update
yum -y -q install amazon-ssm-agent yum-cron-security docker

start amazon-ssm-agent

chkconfig yum-cron on

chkconfig docker on
service docker start

install -o root -g root -m 0700 docker-nextcloud /etc/rc.d/init.d/
install -o root -g root -m 0700 docker-nextcloud.cron 1post-yum-security.cron /etc/cron.daily/
chkconfig docker-nextcloud on

reboot
