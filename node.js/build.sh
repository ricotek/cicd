#!/usr/bin/env bash
# required parameters
BUILD_CMD="${BUILD_CMD:?'BUILD_CMD vars are missing from this repo. Values needed: cicd-build or build.'}"

#  run angular build & tests
npm install
npm run $BUILD_CMD
npm run test