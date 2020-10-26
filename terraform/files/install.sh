mkdir /volume
mount /dev/xvdh /volume || mkfs -t ext4 /dev/xvdh
echo '/dev/xvdh /volume ext4 defaults,nofail 0 2' >> /etc/fstab
mount -a

yum -y -q update
yum -y -q install yum-cron docker

systemctl enable docker
systemctl start docker

install -o root -g root -m 0700 docker-nextcloud /etc/rc.d/init.d/
systemctl enable docker-nextcloud

shutdown -r +1
