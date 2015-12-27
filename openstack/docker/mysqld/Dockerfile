FROM centos:latest
MAINTAINER hans.then@clustervision.com
CMD ["/usr/bin/supervisord", "-c", "/usr/etc/supervisord.conf"]
RUN yum -y swap -- remove systemd-container* -- install systemd systemd-libs
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum -y install python-pip vim-minimal rsyslog mysql mysql-server MySQL-python
RUN pip install supervisor
ADD my.cnf /etc/my.cnf
ADD supervisord.conf /usr/etc/supervisord.conf
VOLUME /var/lib/mysql
EXPOSE 3306
