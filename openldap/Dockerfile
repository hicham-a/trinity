FROM centos:latest
MAINTAINER hicham.amrati@clustervision.com

RUN yum -y install openldap-servers
RUN cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

COPY rootimg /
RUN chown -R ldap. /etc/openldap/ && \
    chmod 600 /etc/openldap/{slapd,cv_local}.conf /etc/openldap/certs/ssl/key

VOLUME /var/lib/ldap

EXPOSE 389
EXPOSE 636

ENTRYPOINT ["slapd", "-f", "/etc/openldap/slapd.conf", "-h", "ldap:/// ldaps:///", "-u", "ldap", "-g", "ldap", "-d0"]
