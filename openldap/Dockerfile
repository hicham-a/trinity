FROM centos:latest
MAINTAINER hicham.amrati@clustervision.com

RUN yum -y install openldap-servers
RUN cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

COPY rootimg /

VOLUME /var/lib/ldap

EXPOSE 389
EXPOSE 636

ENTRYPOINT ["slapd", "-h", "ldap:/// ldaps:///", "-u", "ldap", "-g", "ldap", "-d0"]
