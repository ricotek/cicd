#!/usr/bin/env bash
set -x
dotnet new tool-manifest
dotnet tool install dotnet-sonarscanner --version 5.8.0
dotnet tool install dotnet-reportgenerator-globaltool --version 5.1.9
dotnet tool restore
dotnet sonarscanner begin /k:$BITBUCKET_REPO_SLUG /d:sonar.login=$SONAR_TOKEN /d:sonar.host.url=$SONAR_SERVER /d:sonar.cs.opencover.reportsPaths=$COVERAGE_REPORT_PATH
dotnet restore $SLN_PATH --configfile $NUGET_CONFIG_PATH
dotnet build $SLN_PATH --no-restore --configuration Release
dotnet test $SLN_PATH --configuration Release --collect:"XPlat Code Coverage" --logger:xunit -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=opencover
dotnet reportgenerator -reports:$COVERAGE_REPORT_PATH -targetdir:"CodeCoverageReport" -reporttypes:"Html"
dotnet sonarscanner end /d:sonar.login=$SONAR_TOKEN
dotnet publish $CSPROJ_PATH --output published --configuration Release
set +x