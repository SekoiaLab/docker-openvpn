#!/bin/bash
if [ -z ${OIDC_CLIENT_ID} ] || [ -z ${OIDC_CLIENT_SECRET} ] || [ -z ${OIDC_ENDPOINT_AUTH_URL} ] || [ -z ${OIDC_ENDPOINT_TOKEN_URL} ]; 
then 
    exit 1
fi  

cat > /opt/pam-keycloak-oidc/pam-keycloak-oidc.tml << EOF
client-id="$OIDC_CLIENT_ID"
client-secret="$OIDC_CLIENT_SECRET"
redirect-url="${OIDC_REDIRECT_URL:-urn:ietf:wg:oauth:2.0:oob}"
scope="${OIDC_SCOPE:-pam_roles}"
vpn-user-role="${OIDC_VPN_USER_ROLE:-demo-pam-authentication}"
endpoint-auth-url="$OIDC_ENDPOINT_AUTH_URL"
endpoint-token-url="$OIDC_ENDPOINT_TOKEN_URL"
username-format="%s"
access-token-signing-method="${OIDC_SIGNING_METHOD:-RS256}"
xor-key="${OIDC_XOR_KEY:-supersecret}" 
insecure-mode=${INSECURE_MODE:-false}
EOF
