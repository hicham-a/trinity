FROM centos:centos7
MAINTAINER abhishek.mukherjee@clustervision.com

RUN yum -y install --setopt=tsflags=nodocs epel-release && \ 
    yum -y install --setopt=tsglags=nodocs http://rdo.fedorapeople.org/openstack-juno/rdo-release-juno.rpm && \
    yum -y install --setopt=tsflags=nodocs openstack-selinux openstack-utils && \
    yum -y install --setopt=tsflags=nodocs openstack-dashboard httpd mod_wsgi memcached python-memcached && \
    yum -y install --setopt=tsflags=nodocs python-keystoneclient python-glanceclient python-novaclient python-cinderclient && \ 
    yum -y install --setopt=tsflags-nodocs python-pip && \
    yum -y update && yum clean all

RUN pip install supervisor


EXPOSE 8080 8443 11211
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
COPY rootimg /
#COPY docker-entrypoint.sh /
#COPY supervisord.conf /etc/supervisord.conf
