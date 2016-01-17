FROM centos:centos7
MAINTAINER abhishek.mukherjee@clustervision.com

RUN yum -y swap -- remove systemd-container* -- install systemd systemd-libs
RUN yum -y install --setopt=tsflags=nodocs epel-release && \ 
    yum -y install --setopt=tsflags=nodocs mariadb-server bind-utils pwgen psmisc hostname && \ 
    yum -y install --setopt=tsflags=nodocs python-pip && \
    yum -y update && yum clean all
RUN pip install supervisor

# RUN mysql_install_db --basedir=/var/lib/mysql --datadir=/var/lib/mysql/mysql
# RUN chown -R mysql:mysql /var/lib/mysql

# COPY openstack.sql /
EXPOSE 3306

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"] 
COPY rootimg / 

VOLUME /var/lib/mysql
