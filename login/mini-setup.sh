#! /bin/bash
#title		: login.conf
#description	: Template script to be passed as userdata for login node creation
#author		: Abhishek Mukherjee
#email		: abhishek.mukherjee@clustervision.com

#---------------------------------------------------------------------------
# Enable password authenication 
#---------------------------------------------------------------------------
echo "system" | passwd root --stdin
sed -e 's/[#]*PasswordAuthentication no/PasswordAuthentication yes/g' -i /etc/ssh/sshd_config
service sshd restart


#-------------------------------------------------------------------------
# Wait until the floating ip is up
#-------------------------------------------------------------------------
controller="10.141.255.254"
access=1;
while [ ${access} -ne "0" ]; 
   do ping -c 1 ${controller} ; access=$? ; sleep 1;
done


#--------------------------------------------------------------------------
# Copy the required files from controller to the login node  
#--------------------------------------------------------------------------
mkdir -p /trinity
mount ${controller}:/trinity /trinity
cp -LrT /trinity/login/rootimg /

# Make sure that /tmp is world writable
chmod -R 777 /tmp
chmod +t /tmp


#---------------------------------------------------------------------------
# Setup NFS mounts
#---------------------------------------------------------------------------
cat <<EOF >> /etc/fstab
controller:/cluster/vc-a /cluster nfs rsize=8192,wsize=8192,timeo=14,intr
controller:/trinity /trinity nfs rsize=8192,wsize=8192,timeo=14,intr
controller:/home/vc-a /home nfs rsize=8192,wsize=8192,timeo=14,intr
EOF

for in in {1..5}; do
   if mount -a; then break; fi
   sleep 10
done
if ! mount -a; then
   echo "ERROR: failure to mount file systems."
fi


#--------------------------------------------------------------------------
# Install LDAP
#--------------------------------------------------------------------------
/postscripts/cv_install_slapd
 

#--------------------------------------------------------------------------
# SSH keys for root
#--------------------------------------------------------------------------
mkdir -p /root/.ssh/
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
chown root:root /root/.ssh/id_rsa
chown root:root /root/.ssh/id_rsa.pub
chown root:root /root/.ssh/authorized_keys
chmod uga-rwx /root/.ssh/id_rsa
chmod u+rw /root/.ssh/id_rsa
chmod ga-wx /root/.ssh/id_rsa.pub
chmod ga-wx /root/.ssh/authorized_keys


#---------------------------------------------------------------------------
# Setup permissions
#---------------------------------------------------------------------------
obol -w system group add admin
obol -w system group add power-users
chown root:root /cluster/etc/slurm
chmod ug=rwx,o=rx /cluster/etc/slurm
chown root:admin /cluster/etc/slurm/slurm-user.conf  
chmod ug=rw,o=r /cluster/etc/slurm/slurm-user.conf
chown root:power-users /cluster/apps
chmod ug=rwx,o=rx /cluster/apps
chown root:power-users /cluster/modulefiles
chmod ug=rwx,o=rx /cluster/modulefiles


#---------------------------------------------------------------------------
# Synchronize munge keys.
#---------------------------------------------------------------------------
if [ ! -f /cluster/etc/munge/munge.key ] ; then
    # Create munge key only if it does not exist
    create-munge-key
    su munge -c "cp /etc/munge/munge.key /cluster/etc/munge/munge.key"
else
    # Else copy the existing munge key from the cluster dir
    su munge -c "cp /cluster/etc/munge/munge.key /etc/munge/munge.key"
fi

service munge restart
service slurm restart

