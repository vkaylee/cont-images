#!/usr/bin/env bash
# This shell script is used for github action
workDir="$(pwd)"
pullAndPush(){
  # alpine:3.12.3
  local imageAndTag=$1
  docker pull "${imageAndTag}"
}
# Docker login
# new login with new container registry url and PAT
echo ${{ secrets.CR_PAT }} | docker login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin
# Generate all cache files
find "${workDir}/cache" -type f -name "*.txt" | while IFS= read -r cacheFile
do
  for i in $(<"${cacheFile}");do
    pullAndPush "$i"
  done
done