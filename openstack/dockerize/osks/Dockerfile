FROM centos:centos7
MAINTAINER abhishek.mukherjee@clustervision.com
RUN yum -y swap -- remove systemd-container* -- install systemd systemd-libs
RUN yum -y -q install --setopt=tsflags=nodocs epel-release && \ 
    yum -y -q install --setopt=tsglags=nodocs http://rdo.fedorapeople.org/openstack-juno/rdo-release-juno.rpm && \
    yum -y -q install --setopt=tsflags=nodocs openstack-selinux openstack-utils openstack-keystone python-keystoneclient && \ 
    yum -y -q install --setopt=taglags=nodocs python-pip && \
    yum -y update && yum clean all
VOLUME /var/lib/keystone
RUN pip install supervisor


#RUN keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
#RUN chown -R keystone:keystone /etc/keystone/ssl
#RUN chown -R keystone:keystone /var/log/keystone
#RUN chmod -R o-rwx /etc/keystone/ssl


EXPOSE 5000 35357
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
COPY docker-entrypoint.sh /
COPY keystone.conf /etc/keystone/keystone.conf
COPY supervisord.conf /etc/supervisord.conf
