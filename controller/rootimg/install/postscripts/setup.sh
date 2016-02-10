#! /bin/bash
#title		: login.conf
#description	: Template script to be passed as userdata for login node creation
#author		: Abhishek Mukherjee
#email		: abhishek.mukherjee@clustervision.com

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

if [ ! -f /cluster/etc/munge/munge.key ] ; then 
# Create munge key only if it does not exist
  create-munge-key
  su munge -c "cp /etc/munge/munge.key /cluster/etc/munge/munge.key"
else
# Else copy the existing munge key from the cluster dir
  su munge -c "cp /cluster/etc/munge/munge.key /etc/munge/munge.key"
fi  

#--------------------------------------------------------------------------
# Install LDAP
#--------------------------------------------------------------------------

/postscripts/cv_install_slapd

##-- The following commented lines should be removed after successful testing
##yum -y -q install openldap openldap-clients openldap-servers
##cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
##chkconfig slapd on
##service slapd start
##
##rm -rf /etc/openldap/slapd.d
##cp -LrT /trinity/openldap/rootimg/etc/openldap /etc/openldap
##
##systemctl restart slapd
##
###--------------------------------------------------------------------------
### Setup the initial database
###--------------------------------------------------------------------------
##ldapadd -D cn=Manager,dc=local -w system << EOF
##dn: dc=local
##dc: local
##objectClass: domain
##
##dn: ou=People,dc=local
##ou: People
##objectClass: top
##objectClass: organizationalUnit
##
##dn: ou=Group,dc=local
##ou: Group
##objectClass: top
##objectClass: organizationalUnit
##
##dn: cn=uid,dc=local
##cn: uid
##objectClass: uidNext
##uidNumber: 1050
##
##dn: cn=gid,dc=local
##cn: gid
##objectClass: uidNext
##uidNumber: 150
##EOF
##
###--------------------------------------------------------------------------
### Setup PAM
###--------------------------------------------------------------------------
##yum -y -q install nss-pam-ldapd authconfig
##
### append our config to the ldap nameserver demon
##cat >> /etc/nslcd.conf << EOF 
##uri ldap://localhost
##ssl no
##tls_cacertdir /etc/openldap/cacerts
##base group ou=Group,dc=local
##base passwd ou=People,dc=local
##base shadow ou=People,dc=local
##EOF
##
### configure the ldap server. Not sure this is needed.
##cat >> /etc/pam_ldap.conf << EOF
##uri ldap://localhost/
##base dc=local
##ssl no
##tls_cacertdir /etc/openldap/cacerts
##pam_password md5
##EOF
##
### setup nssswitch
##sed -e 's/^group:.*$/group:\t\tfiles ldap/g' \
##    -e 's/^passwd:.*$/passwd:\t\tfiles ldap/g' \
##    -e 's/^shadow:.*$/shadow:\t\tfiles ldap/g' \
##    -i /etc/nsswitch.conf 
##
##authconfig-tui --kickstart --enableldapauth --ldapbasedn=dc=local --ldapserver=localhost

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

