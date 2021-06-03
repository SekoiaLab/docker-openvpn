#!/bin/bash
if [ -z ${OIDC_CLIENT_ID} ] || [ -z ${OIDC_CLIENT_SECRET} ] || [ -z ${OIDC_ENDPOINT_AUTH_URL} ] || [ -z ${OIDC_ENDPOINT_TOKEN_URL} ]; 
then 
    exit 1
fi  

cat > /opt/pam-keycloak-oidc/pam-keycloak-oidc.tml << EOF
# name of the dedicated OIDC client at Keycloak
client-id="$OIDC_CLIENT_ID"

# the secret of the dedicated client
client-secret="$OIDC_CLIENT_SECRET"

# special callback address for no callback scenario
redirect-url="${OIDC_REDIRECT_URL:-urn:ietf:wg:oauth:2.0:oob}"

# OAuth2 scope to be requested, which contains the role information of a user
scope="${OIDC_SCOPE:-pam_roles}"

# name of the role to be matched, only Keycloak users who is assigned with this role could be accepted
vpn-user-role="${OIDC_VPN_USER_ROLE:-demo-pam-authentication}"

# retrieve from the meta-data at https://keycloak.example.com/auth/realms/demo-pam/.well-known/openid-configuration
endpoint-auth-url="$OIDC_ENDPOINT_AUTH_URL"
endpoint-token-url="$OIDC_ENDPOINT_TOKEN_URL"

# 1:1 copy, to fmt substituion is required
username-format="%s"

# to be the same as the particular Keycloak client
access-token-signing-method="${OIDC_SIGNING_METHOD:-RS256}"

# a key for XOR masking. treat it as a top secret
xor-key="${OIDC_XOR_KEY:-supersecret}" 
EOF
