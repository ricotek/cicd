#!/usr/bin/env bash
set -x
cd test
newman --version
newman run vps.coracare.$COMPONENT.postman_collection.json -e vps.coracare.$COMPONENT.postman_environment.json --env-var baseUri=https://$BITBUCKET_DEPLOYMENT_ENVIRONMENT-$COMPONENT.coracare.vitacarerx.com --env-var crmApiUri=https://$BITBUCKET_DEPLOYMENT_ENVIRONMENT-crm.coracare.vitacarerx.com/api --env-var userApiUri=https://$BITBUCKET_DEPLOYMENT_ENVIRONMENT-users.api.coracare.vitacarerx.com --disable-unicode --reporters -r htmlextra --reporter-htmlextra-title "Prescriptions API Report $BITBUCKET_DEPLOYMENT_ENVIRONMENT-ENVIRONMENT" $BITBUCKET_DEPLOYMENT_ENVIRONMENT --reporter-htmlextra-export newman/$COMPONENT.html
set +x