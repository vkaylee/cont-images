#!/usr/bin/env bash
# This shell script is used for github action
workDir="$(pwd)"
pullAndPush(){
  # alpine:3.12.3
  local imageAndTag=$1
  githubImageAndTag="ghcr.io/${GITHUB_REPOSITORY}:$(echo "${imageAndTag}" | tr ":" "-")"
  # If it does not exist in github registry
  if ! docker pull "${githubImageAndTag}"; then
    # If it exists in docker hub
    if docker pull "${imageAndTag}"; then
      docker tag "${imageAndTag}" "${githubImageAndTag}"
      docker push "${githubImageAndTag}"
    fi
  fi
}
# Generate all cache files
find "${workDir}/cache" -type f -name "*.txt" | while IFS= read -r cacheFile
do
  for i in $(<"${cacheFile}");do
    pullAndPush "$i"
  done
done