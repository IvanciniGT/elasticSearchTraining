
sudo swapoff -a   
cat vim /etc/fstab 

sudo su -
ulimit -n 65535
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
exit
