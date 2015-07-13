FROM centos:centos7
MAINTAINER abhishek.mukherjee@clustervision.com

RUN yum -y install --setopt=tsflags=nodocs epel-release && \
    yum -y install --setopt=tsflags=nodocs pwgen wget logrotate rabbitmq-server && \
    yum -y install --setopt=tsflags=nodocs python-pip &&\
    yum -y update && yum clean all
RUN /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
RUN pip install supervisor

# 
# expose some ports
#
# 5672 rabbitmq-server - amqp port
# 15672 rabbitmq-server - for management plugin
# 4369 epmd - for clustering
# 25672 rabbitmq-server - for clustering
EXPOSE 5672 15672 4369 25672
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
COPY supervisord.conf /etc/supervisord.conf
COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config
