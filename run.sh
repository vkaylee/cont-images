#!/usr/bin/env bash
# This shell script is used for github action
workDir="$(pwd)"
pullAndPush(){
  # alpine:3.12.3
  local imageAndTag=$1
  docker pull "${imageAndTag}"
}
# Generate all cache files
find "${workDir}/cache" -type f -name "*.txt" | while IFS= read -r cacheFile
do
  for i in $(<"${cacheFile}");do
    pullAndPush "$i"
  done
done