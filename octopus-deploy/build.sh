#!/bin/sh
set -x
octo push --package $CHART_FULL_PATH-$VERSION.tgz --server $OCTOPUS_SERVER_EXT --apiKey $OCTOPUS_APIKEY
octo create-release --server $OCTOPUS_SERVER_EXT --apiKey $OCTOPUS_APIKEY --project $BITBUCKET_REPO_SLUG.k8s --deployto $BITBUCKET_DEPLOYMENT_ENVIRONMENT --waitForDeployment --guidedFailure True --packageVersion $VERSION --version $VERSION --enableservicemessages --progress
set +x