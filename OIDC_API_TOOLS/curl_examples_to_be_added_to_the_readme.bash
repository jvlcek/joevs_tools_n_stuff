#!/usr/bin/env bash

set -x

user="user1"                                                                                                                                  # The user to be authenticated
password="smartvm"                                                                                                                            # The password for the user being authenticated
servername="example-miq-httpd.10.8.96.54.xip.io"                                                                                              # The ManageIQ server name. ServerName from the config file without the https:// e.g.  my-miq.example.com
oidcclientsecret="12345678-1234-1234-1234-01234567abcd"                                                                                       # OIDCClientSecret from the OpenID-Connect configuration.
oidcclientid="example-oidc"                                                                                                                   # OIDCClientID from the OpenID-Connect configuration.
oidcoauthintrospectionendpoint="https://keycloak-example-keycloak.10.8.96.54.nip.io/auth/realms/miq/protocol/openid-connect/token/introspect" # OIDCOauthIntrospectionEndpoint from the OpenID-Connect configuration
oidcprovidertokenendpoint="https://keycloak-example-keycloak.10.8.96.54.nip.io/auth/realms/miq/protocol/openid-connect/token/"                # OIDCProviderTokenEndpoint. Or OIDCOauthIntrospectionEndpoint without the trailing "introspect" part from the OpenID-Connect configurationt


# ----------------------------------------------------------------------
# # *** Accessing the ManageIQ API with a JWT Token
# ----------------------------------------------------------------------

   # ----------------------------------------------------------------------
   # # *** Step 1: Request the JWT Token from the OpenID-Connect Provider
   # ----------------------------------------------------------------------

   jwt_token=$(curl -k -L --user ${user}:${password} -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password" -d "client_id=${oidcclientid}" -d "client_secret=${oidcclientsecret}" -d "username=${user}" -d "password=${password}" ${oidcprovidertokenendpoint} )

   # ----------------------------------------------------------------------
   # *** Step 2: Retrieve the access_token from the the JWT
   # ----------------------------------------------------------------------

   access_token=$(echo $jwt_token | jq -r '.access_token')
   
   # ----------------------------------------------------------------------
   # *** Step 3 (OPTIONAL) Use the access_token to do Token Introspection
   # ----------------------------------------------------------------------

   curl -k -L --user ${oidcclientid}:${oidcclientsecret} -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "token=${access_token}" ${oidcoauthintrospectionendpoint}


   # ----------------------------------------------------------------------
   # *** Step 4: Accessing MiQ API using the JWT:
   # ----------------------------------------------------------------------
   curl -L -vvv -k -X GET -H "Authorization: Bearer ${access_token}" https://${servername}/api/users | jq

# ----------------------------------------------------------------------
# *** Accessing the ManageIQ API using a ManageIQ API Auth Token
# ----------------------------------------------------------------------

   # ----------------------------------------------------------------------
   # *** Step 1: Request the JWT Token from the OpenID-Connect Provider
   # ----------------------------------------------------------------------

   jwt_token=$(curl -k -L --user ${user}:${password} -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password" -d "client_id=${oidcclientid}" -d "client_secret=${oidcclientsecret}" -d "username=${user}" -d "password=${password}" ${oidcprovidertokenendpoint} )

   # ----------------------------------------------------------------------
   # *** Step 2: Retrieve the access_token from the the JWT
   # ----------------------------------------------------------------------

   access_token=$(echo $jwt_token | jq -r '.access_token')

   # ----------------------------------------------------------------------
   # *** Step 3: (OPTIONAL) Use the access_token to do Token Introspection
   # ----------------------------------------------------------------------

   curl -k -L --user ${oidcclientid}:${oidcclientsecret} -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "token=${access_token}" ${oidcoauthintrospectionendpoint}

   # ----------------------------------------------------------------------
   # *** Step 4: Request an MiQ API Authentication Token:
   # ----------------------------------------------------------------------

   result=$(curl -L -vvv -k -X GET -H "Authorization: Bearer ${access_token}" https://${servername}/api/auth)

   # ----------------------------------------------------------------------
   # *** Step 5: Retrieve the API authentication token from the result
   # ----------------------------------------------------------------------

   api_auth_token=`echo $result | jq -r '.auth_token'`

   # ----------------------------------------------------------------------
   # *** Step 6: Accessing MiQ API Using the MiQ API Auth Token:
   # ----------------------------------------------------------------------

   curl -L -vvv -k -X GET  -H "Accept: application/json" -H "X-Auth-Token: ${api_auth_token}" https://${servername}/api/users | jq

# ----------------------------------------------------------------------
# *** Accessing the MiQ API Using basic admin:password
# ----------------------------------------------------------------------

  # The ManageIQ OpenID-Connect configuration treats the admin user as
  #   a special case.
  #
  # The admin user is not authenticated by the OpenID-Connect Provider.

   curl -L -vvv -k --user admin:${password} -X GET -H 'Accept: application/json' https://${servername}/api/users | jq

