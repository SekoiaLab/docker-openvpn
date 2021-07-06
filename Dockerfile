# Original credits: https://github.com/jpetazzo/dockvpn, https://github.com/kylemanna/docker-openvpn
FROM debian:stable
LABEL maintainer="Théo Lépine <theo.lepine@sekoia.fr"
ARG PAM_KEYCLOAK_OIDC_VERSION=r1.1.7

RUN apt-get update && \ 
    apt-get install -y openvpn iptables bash easy-rsa libqrencode4 wget && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apt/*


# PAM module Keycloak OIDC: https://github.com/zhaow-de/pam-keycloak-oidc
RUN mkdir /opt/pam-keycloak-oidc
RUN wget -q -O /opt/pam-keycloak-oidc/pam-keycloak-oidc https://github.com/SekoiaLab/pam-keycloak-oidc/releases/download/$PAM_KEYCLOAK_OIDC_VERSION/pam-keycloak-oidc.linux-amd64 && \
    chmod 755 /opt/pam-keycloak-oidc/pam-keycloak-oidc

# Script for Keycloak/OIDC module configuration generation
COPY ./pam/openvpn-keycloak-oidc /etc/pam.d/
COPY ./utils/generate-config.sh /opt/

# Init script
COPY ./utils/init.sh /opt/

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki
VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["/opt/init.sh"]

COPY ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

