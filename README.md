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

### 1. Docker image build

      docker build -t <image_name> .

### 2. OAuth client configuration

Keycloak will be used as an example. 

1.  Create a new Role at Keycloak, e.g. `demo-pam-authentication`. (Assuming the server is at
    `https://keycloak.example.com`)

2.  Create a new Client Scope, e.g. `pam_roles`:
    * Protocol: `openid-connect`
    * Display On Consent Screen: `OFF`
    * Include in Token Scope: `ON`
    * Mapper:
        * Name: e.g. `pam roles`
        * Mapper Type: `User Realm Role`
        * Multivalued: `ON`
        * Token Claim Name: `pam_roles` (the name of the Client Scope)
        * Claim JSON Type: `String`
        * Add to ID token: `OFF`
        * Add to access token: `ON`
        * Add to userinfo: `OFF`
    * Scope:
        * Effective Roles: `demo-pam-authentication` (the name of the Role)

3.  Create a new Keycloak Client:
    * Client ID: `demo-pam` (or whatever valid client name)
    * Enabled: `ON`
    * Consent Required: `OFF`
    * Client Protocol: `openid-connect`
    * Access Type: `confidential`
    * Standard Flow Enabled: `ON`
    * Implicit Flow Enabled: `OFF`
    * Direct Access Grants Enabled: `ON`
    * Service Accounts Enabled: `OFF`
    * Authorization Enabled: `OFF`
    * Valid Redirect URIs: `urn:ietf:wg:oauth:2.0:oob`
    * Fine Grain OpenID Connect Configuration:
        * Access Token Signature Algorithm: e.g. `RS256`
    * Client Scopes:
        * Assigned Default Client Scopes: `pam_roles`
    * Scope:
        * Full Scope Allowed: `OFF`
        * Effective Roles: `demo-pam-authentication`
       
4.  Assign the role `demo-pam-authentication` to relevant users. A common practice is to assign the role to a Group,
    then make the relevant users join that group.

### 3. OpenVPN server configuration

* Initialize the OpenVPN server configuration.
      
      docker run -v /srv/openvpn:/etc/openvpn --rm <image_name> ovpn_genconfig -s 10.10.100.0/24 -n 10.10.1.1 -u udp://vpn.domain.local

* Intialize the PKI

      docker run -v /srv/openvpn:/etc/openvpn --rm -it <image_name> ovpn_initpki nopass

### 4. OpenVPN client configuration

Get the OpenVPN client configuration.

      docker run -v /srv/openvpn:/etc/openvpn --rm <image_name> ovpn_getclient > client.ovpn

### 5. OpenVPN server launch

TODO

## Remarks

### Authentication & Encryption

* This image is designed to use solely an OAuth authentication and does not provide certificates or keys for clients. 
* The server identity is checked with the CA certificate hardcoded in the client configuration. 
* TLS keys are used to negotiate a secured channel.

### OAuth

* The OAuth requests are made through a PAM module.
* A modified version of [zhaow-de/pam-keycloak-oidc](https://github.com/zhaow-de/pam-keycloak-oidc) is used.
