# Check if parameter is set
if [ $# -eq 0 ]
then
    echo "Precise a VM name !"
    exit 1
fi
vm_name=$1

# CREATE & start VM
lxc-create -t download -n $vm_name -- -d debian -r bullseye -a amd64
lxc-start -n $vm_name

# GENERATE SCRIPT
cat << EOF > /var/lib/lxc/$vm_name/rootfs/home/init
sed -i 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
locale-gen --purge fr_FR.UTF-8
update-locale LANG=fr_FR.UTF-8
PATH="\$PATH:/sbin:/usr/sbin"
apt update -y
apt install ssh sudo -y
adduser --disabled-password  --gecos "" user
usermod -aG sudo user
EOF
chmod +x /var/lib/lxc/$vm_name/rootfs/home/init

# EXECUTE SCRIPT ON VM
lxc-attach -n $vm_name -- /home/init

echo "VM created and setuped !"
