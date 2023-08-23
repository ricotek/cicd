#!/usr/bin/env bash
set -x
cp -a /templates $CHART_PATH_ARGO
cd $CHART_PATH_ARGO
helm package . --version $VERSION --app-version $VERSION
set +x