#!/usr/bin/env bash
set -x
cd test
newman --version
newman run $COMPONENT.postman_collection.json -e $COMPONENT.postman_environment.json --env-var baseUri=https://$BITBUCKET_DEPLOYMENT_ENVIRONMENT-$COMPONENT.$DOMAIN--env-var crmApiUri=https://$BITBUCKET_DEPLOYMENT_ENVIRONMENT-crm.coracare.vitacarerx.com/api --env-var userApiUri=https://$BITBUCKET_DEPLOYMENT_ENVIRONMENT-users.api.$DOMAIN--disable-unicode --reporters -r htmlextra --reporter-htmlextra-title "Prescriptions API Report $BITBUCKET_DEPLOYMENT_ENVIRONMENT-ENVIRONMENT" $BITBUCKET_DEPLOYMENT_ENVIRONMENT --reporter-htmlextra-export newman/$COMPONENT.html
set +x