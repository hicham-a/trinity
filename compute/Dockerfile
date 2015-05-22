FROM centos:latest
MAINTAINER hans.then@clustervision.com
RUN yum -y install epel-release
RUN useradd munge -u 1002 -U
RUN useradd slurm -u 1001 -U
RUN yum -y install openssh-server openssh-clients python-pip vim-minimal infiniband-diags munge rsyslog bind-utils perl perl-DBI perl-Switch
RUN yum -y install openldap-clients nss-pam-ldapd authconfig environment-modules
RUN yum -y install infinipath-psm
RUN yum -y groupinstall "Infiniband Support"
RUN pip install supervisor
RUN mkdir -p /var/run/sshd ; chmod -rx /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
#RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config 
#RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
#RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -ri 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
ADD nsswitch.conf /etc/nsswitch.conf
ADD pam_ldap.conf /etc/pam_ldap.conf
ADD nslcd.conf /etc/nslcd.conf
ADD pam.d/ /etc/pam.d

RUN mkdir /var/run/slurm /var/spool/slurm /var/log/slurm; 
#RUN chown slurm:slurm /var/run/slurm /var/spool/slurm /var/log/slurm
RUN mkdir -m 755 -p /var/run/munge
RUN chown munge:munge /var/run/munge
ADD supervisord.conf /usr/etc/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/usr/etc/supervisord.conf"]
ADD rpms /rpms
RUN rpm -ivh /rpms/*.rpm
