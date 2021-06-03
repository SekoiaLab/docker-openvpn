# OpenVPN for Docker with OAuth authentication support

Based on [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn) & [zhaow-de/pam-keycloak-oidc](https://github.com/zhaow-de/pam-keycloak-oidc). 
Additional documentation can be found on the respective repositories.

*Disclaimer* : I'm not an OpenVPN/OAuth expert, therefore this project might not respect the best practices. Use it at your own risk.

## Installation

This example will use the following paths and variables:

* `/srv/openvpn` for the location on the host machine of OpenVPN configuration files that will be mounted on the container as a volume.
* `10.10.100.0/24` for the network range used for VPN clients
* `10.10.1.1` for the DNS server
* `vpn.domain.local` for the public domain name

### Docker image build

      docker build -t <image_name> .

### OAuth client configuration

Keycloak will be used as an example. 

TODO

### OpenVPN server configuration

* Initialize the OpenVPN server configuration.
      
      docker run -v /srv/openvpn:/etc/openvpn --rm <image_name> ovpn_genconfig -s 10.10.100.0/24 -n 10.10.1.1 -u udp://vpn.domain.local

* Intialize the PKI

      docker run -v /srv/openvpn:/etc/openvpn --rm -it <image_name> ovpn_initpki nopass

### OpenVPN client configuration

Get the OpenVPN client configuration.

      docker run -v /srv/openvpn:/etc/openvpn --rm <image_name> ovpn_getclient > client.ovpn

## Internals

### Authentication & Encryption

* This image is designed to use solely an OAuth authentication and does not provide certificates or keys for clients. 
* The server identity is checked with the CA certificate hardcoded in the client configuration. 
* TLS keys are used to negotiate a secured channel.

### OAuth

* The OAuth requests are made through a PAM module.
* A modified version of [zhaow-de/pam-keycloak-oidc](https://github.com/zhaow-de/pam-keycloak-oidc) is used.
