# We can only install xCAT on centos6. On Centos 7 I ran into a lot of trouble due to the "logical naming" of device networks.
FROM centos:centos6
RUN yum -y install wget
# ADD does not work, it retrieves some html file.
RUN wget http://sourceforge.net/projects/xcat/files/yum/2.8/xcat-core/xCAT-core.repo -O /etc/yum.repos.d/xCAT-core.repo
RUN wget http://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/x86_64/xCAT-dep.repo -O /etc/yum.repos.d/xCAT-dep.repo
RUN yum -y install xCAT rsyslog
# Todo: find a better location to store the tables.
ADD tables /tmp/tables
RUN service xcatd start; source /etc/profile.d/xcat.sh; /opt/xcat/sbin/restorexCATdb -p /tmp/tables; mknb x86_64
ADD dhcpd.conf /etc/dhcp/dhcpd.conf
