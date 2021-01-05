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
  githubImageAndTag="ghcr.io/${GITHUB_REPOSITORY}:$(echo "${dockerImageAndTag}" | tr ":" "-")"

  local isDockerImageExisted=false
  local isGithubImageExisted=false
  # Check existed
  if docker pull "${githubImageAndTag}"; then
    isGithubImageExisted=true
  else
    if docker pull "${dockerImageAndTag}"; then
      isDockerImageExisted=true
    fi
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
  printMdTableRow "${dockerImageAndTag}" "${githubImageAndTag}" "${readmeFile}"
}
printMdTableRow() {
  printf '%s | %s \n' "$1" "$2" >> "$3"
}
# Create README.temp.md
readmeFile="${workDir}/README.md"
repoReadmeFile="${workDir}/REPO_README.md"
if [ ! -f "${readmeFile}" ]; then
  touch "${readmeFile}"
fi
if [ ! -f "${repoReadmeFile}" ]; then
  touch "${repoReadmeFile}"
fi
# Update readme file
cat "${repoReadmeFile}" > "${readmeFile}"
printf '\n## List Images\n' >> "${readmeFile}"
printMdTableRow 'Docker hub image' 'Github image' "${readmeFile}"
printMdTableRow '----------------' '------------' "${readmeFile}"

# Generate all cache files
find "${workDir}/cache" -type f -name "*.txt" | sort | while IFS= read -r cacheFile; do
  for i in $(<"${cacheFile}"); do
    run "$i"
  done
done