#!/usr/bin/env bash
# config found here, Using the GitVersion CLI tool: https://gitversion.net/docs/reference/build-servers/bitbucket-pipelines
export PATH="$PATH:/root/.dotnet/tools"
dotnet new tool-manifest
dotnet tool install GitVersion.Tool --version 5.10.3
dotnet tool restore
dotnet gitversion /output buildserver