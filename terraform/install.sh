mkdir /volume
mount /dev/xvdh /volume || mkfs -t ext4 /dev/xvdh
echo '/dev/xvdh /volume ext4 defaults,nofail 0 2' >> /etc/fstab
mount -a

yum -y -q update
yum -y -q install yum-cron-security docker

chkconfig yum-cron on

chkconfig docker on
service docker start

chmod +x docker-nextcloud docker-nextcloud.cron
cp docker-nextcloud /etc/rc.d/init.d/
cp docker-nextcloud.cron /etc/cron.daily/
chkconfig docker-nextcloud on
service docker-nextcloud run

reboot
