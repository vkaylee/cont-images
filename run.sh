#!/usr/bin/env bash
# This shell script is used for github action
workDir="$(pwd)"

pullAndPush() {
  local dockerImageAndTag=$1
  local githubImageAndTag=$2

  docker pull "${dockerImageAndTag}"
  docker tag "${dockerImageAndTag}" "${githubImageAndTag}"
  docker push "${githubImageAndTag}"
}
run() {
  # alpine:3.12.3
  local dockerImageAndTag
  dockerImageAndTag=$1
  local githubImageAndTag
  githubImageAndTag="ghcr.io/${GITHUB_REPOSITORY}:$(tr ":" "-" "${dockerImageAndTag}")"

  local isDockerImageExisted=false
  local isGithubImageExisted=false
  # Check existed
  if docker pull "${githubImageAndTag}"; then
    isGithubImageExisted=true
  fi
  if docker pull "${dockerImageAndTag}"; then
    isDockerImageExisted=true
  fi
  # Pull and push
  if [ "${isGithubImageExisted}" = false ] && [ "${isDockerImageExisted}" = true ]; then
    pullAndPush "${dockerImageAndTag}" "${githubImageAndTag}"
  fi
  # generate readme
  if [ "${isGithubImageExisted}" = true ]; then
    generateReadme "${dockerImageAndTag}" "${githubImageAndTag}"
  fi

}
generateReadme() {
  local dockerImageAndTag=$1
  local githubImageAndTag=$2
  tee README.md << END
## List Mariadb
  - asd
  - asd
  - asd
END
  cat README.md
}
# Generate all cache files
find "${workDir}/cache" -type f -name "*.txt" | while IFS= read -r cacheFile; do
  for i in $(<"${cacheFile}"); do
    run "$i"
  done
done
