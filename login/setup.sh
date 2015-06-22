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
# Set hostname and domainname 
#--------------------------------------------------------------------------
echo “login” >> /etc/hostname
hostname login.vc-a
#domainname vc-a

#--------------------------------------------------------------------------
# Copy the required files from controller to the login node  
#--------------------------------------------------------------------------
mkdir -p /trinity
mount ${controller}:/trinity /trinity
cp --dereference --recursive --verbose --preserve /trinity/login/rootimg/* /

#---------------------------------------------------------------------------
# Hostname resolution
#---------------------------------------------------------------------------
##cp-rootimg
##cat << EOF > /etc/resolv.conf
##search cluster. vc-a. cluster
##nameserver 10.141.255.254
##EOF

read ETH1 <<<$(ls /sys/class/net/ | grep "^e" | sort | head -1)
sed -e 's/^PEERDNS="yes"/PEERDNS="no"/g' \
    -i /etc/sysconfig/network-scripts/ifcfg-${ETH1}

#---------------------------------------------------------------------------
# Setup NFS mounts
#---------------------------------------------------------------------------
mkdir -p /cluster
mkdir -p /home
##sort -u /etc/fstab* | \
##  awk '
##    BEGIN {print "# Created by trinity";}; \
##    {if ($0!~/^\#/ && $0 !~/^$/) {if ($0~/nfs/) {nfs=nfs RS $0} else {local=local RS $0}}}; \
##    END {print "# local filesystems" local RS "# remote filesystems" nfs}
##  ' > /tmp/fstab
##rm /etc/fstab*
##mv /tmp/fstab /etc/fstab
##mount -a
#AM: For now we will use the HERE document
cat <<EOF >> /etc/fstab
controller:/cluster/vc-a /cluster nfs rsize=8192,wsize=8192,timeo=14,intr
controller:/trinity /trinity nfs rsize=8192,wsize=8192,timeo=14,intr
controller:/home/vc-a /home nfs rsize=8192,wsize=8192,timeo=14,intr
EOF

mount-a

#--------------------------------------------------------------------------
# Setup munge and SLURM 
#--------------------------------------------------------------------------
# centos user had uid = 1000!
groupadd -g 1002 munge 
useradd -u 1002 -g 1002 munge
groupadd -g 1001 slurm
useradd -u 1001 -g 1001 slurm

yum -y install epel-release
yum -y install munge munge-libs gcc
yum -y install readline-devel openssl-devel perl-ExtUtils-MakeMaker perl-Switch pam-devel
yum -y install /trinity/login/rpms/slurm*.rpm
rm -rf /etc/slurm/*
rmdir /etc/slurm
ln -s /cluster/etc/slurm /etc/
if [ ! -f /cluster/etc/munge/munge.key ] ; then 
# Create munge key only if it does not exist
  create-munge-key
  su munge -c "cp /etc/munge/munge.key /cluster/etc/munge/munge.key"
else
# Else copy the existing munge key from the cluster dir
  su munge -c "cp /cluster/etc/munge/munge.key /etc/munge/munge.key"
fi  
mkdir -p /var/log/slurm
chown -R slurm:slurm /var/log/slurm

#AM: Moved to the end
# service munge start
# service slurm start
# chkconfig munge on
# chkconfig slurm on

#--------------------------------------------------------------------------
# Install LDAP
#--------------------------------------------------------------------------

yum -y install openldap openldap-clients openldap-servers
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chkconfig slapd on
service slapd start

ldapmodify -Y EXTERNAL -H ldapi:/// << EOF
dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: system
-
replace: olcSuffix
olcSuffix: dc=cluster
-
replace: olcRootDN
olcRootDN: cn=Manager,dc=cluster
EOF

#--------------------------------------------------------------------------
# Install the required schema's + custom one for the uid
#--------------------------------------------------------------------------
slapadd -n 0  -l /etc/openldap/schema/cosine.ldif
slapadd -n 0  -l /etc/openldap/schema/nis.ldif
slapadd -n 0  -l /etc/openldap/schema/inetorgperson.ldif

##cp-rootimg
##cat > /tmp/trinity.ldif << EOF
##dn: cn=trinity,cn=schema,cn=config
##objectClass: olcSchemaConfig
##cn: trinity
##olcObjectClasses: {0}( 1.3.6.1.4.1.19173.2.2.2.8
## NAME 'uidNext'
## DESC 'Where we get the next uidNumber from'
## MUST ( cn $ uidNumber ) )
##EOF

slapadd -n 0  -l /tmp/trinity.ldif

chown ldap:ldap /etc/openldap/slapd.d/cn\=config/cn\=schema/*
systemctl restart slapd

#--------------------------------------------------------------------------
# Setup the initial database
#--------------------------------------------------------------------------
ldapadd -D cn=Manager,dc=cluster -w system << EOF
dn: dc=cluster
dc: cluster
objectClass: domain

dn: ou=People,dc=cluster
ou: People
objectClass: top
objectClass: organizationalUnit

dn: ou=Group,dc=cluster
ou: Group
objectClass: top
objectClass: organizationalUnit

dn: cn=uid,dc=cluster
cn: uid
objectClass: uidNext
uidNumber: 1050

dn: cn=gid,dc=cluster
cn: gid
objectClass: uidNext
uidNumber: 150
EOF

#--------------------------------------------------------------------------
# Change access rights to allow for PAM users to authenticate
#--------------------------------------------------------------------------
ldapmodify -Y EXTERNAL -H ldapi:/// << EOF
dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: to attrs=userPassword by self write by anonymous auth by * none
-
add: olcAccess
olcAccess: to * by self write by * read
EOF

#--------------------------------------------------------------------------
# Setup PAM
#--------------------------------------------------------------------------
yum -y install nss-pam-ldapd authconfig

# append our config to the ldap nameserver demon
cat >> /etc/nslcd.conf << EOF 
uri ldap://localhost
ssl no
tls_cacertdir /etc/openldap/cacerts
base   group  ou=Group,dc=cluster
base   passwd ou=People,dc=cluster
base   shadow ou=People,dc=cluster
EOF

# configure the ldap server. Not sure this is needed.
cat >> /etc/pam_ldap.conf << EOF
uri ldap://localhost/
base dc=cluster
ssl no
tls_cacertdir /etc/openldap/cacerts
pam_password md5
EOF

# setup nssswitch
sed -e 's/^group:.*$/group:\t\tfiles ldap/g' \
    -e 's/^passwd:.*$/passwd:\t\tfiles ldap/g' \
    -e 's/^shadow:.*$/shadow:\t\tfiles ldap/g' \
    -i /etc/nsswitch.conf 

authconfig-tui --kickstart --enableldapauth --ldapbasedn=dc=cluster --ldapserver=localhost


#---------------------------------------------------------------------------
# Environment modules
#---------------------------------------------------------------------------
yum -y install environment-modules
rm /usr/share/Modules/init/.modulespath 
ln -s /cluster/.modulespath /usr/share/Modules/init/.modulespath
#cat << EOF >> /usr/share/Modules/init/.modulespath
#/trinity/clustervision/modulefiles
#/cluster/modulefiles
#EOF

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
# User Manager
#---------------------------------------------------------------------------
yum -y install python-ldap python-retrying
##cp-rootimg
##cp /trinity/login/obol/obol /usr/sbin/
chmod u=x,go= /usr/sbin/obol

#---------------------------------------------------------------------------
# No strict host checking for the virtual cluster
#---------------------------------------------------------------------------
FLOATING_IP=127.0.0.1
VC_NET=$(echo ${FLOATING_IP} | awk -F. '{ print $1"."$2".*.*" }')
cat << EOF >> /etc/ssh/ssh_config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null  
EOF
service sshd restart


#---------------------------------------------------------------------------
# Remote X11
#---------------------------------------------------------------------------
yum -y install xorg-x11-xauth

#---------------------------------------------------------------------------
# Other packages
#---------------------------------------------------------------------------
yum -y install bind-utils
yum -y install python-pip python-ldap python-retrying
yum -y install git


#---------------------------------------------------------------------------
# Setup permissions
#---------------------------------------------------------------------------
obol group add admin
obol group add power-users
chown root:root /cluster/etc/slurm
chmod ug=rwx,o=rx /cluster/etc/slurm
chown root:admin /cluster/etc/slurm/slurm-user.conf  
chmod ug=rw,o=r /cluster/etc/slurm/slurm-user.conf
chown root:power-users /cluster/apps
chmod ug=rwx,o=rx /cluster/apps
chown root:power-users /cluster/modulefiles
chmod ug=rwx,o=rx /cluster/modulefiles

#---------------------------------------------------------------------------
# Start munge and slurm
#---------------------------------------------------------------------------
##cp-rootimg
##mkdir -p /etc/systemd/system/munge.service.d
##cat << EOF > /etc/systemd/system/munge.service.d/customexec.conf
##[Service]
##ExecStart=
##ExecStart=/usr/sbin/munged  --key-file /cluster/etc/munge/munge.key
##EOF

service munge start
service slurm start
chkconfig munge on
chkconfig slurm on

#---------------------------------------------------------------------------
# Setup security limits
# Fix for #174
#---------------------------------------------------------------------------
##cp-rootimg
##cat << EOF > /etc/security/limits.d/trinity.conf
##*               -       stack           unlimited
##*               -       memlock         unlimited
##EOF 
##
##cat << EOF > /etc/sysconfig/slurm
##ulimit -l unlimited
##ulimit -s unlimited
##EOF
