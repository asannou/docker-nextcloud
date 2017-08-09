mkdir /volume
mount /dev/xvdh /volume || mkfs -t ext4 /dev/xvdh
echo '/dev/xvdh /volume ext4 defaults,nofail 0 2' >> /etc/fstab
mount -a

yum -y -q update
yum -y -q install amazon-ssm-agent docker

start amazon-ssm-agent

chkconfig docker on
service docker start

install -o root -g root -m 0700 docker-nextcloud /etc/rc.d/init.d/
chkconfig docker-nextcloud on

reboot
