#!/bin/bash
set -e
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

containers="qwc-admin-gui qwc-config-service qwc-data-service qwc-map-viewer qwc-ogc-service"

declare -A git_versions

for ctr in $containers; do
  printf "${YELLOW}${ctr}${NC}\n\n"
  git_version=$(git ls-remote https://github.com/qwc-services/$ctr HEAD | cut -f 1)
  git_versions[$ctr]=$git_version
  docker-compose build --build-arg GIT_VERSION=$git_version $ctr
  printf "\n================================================================================\n"
done

printf "${YELLOW}qwc-auth-service${NC}\n\n"
AUTH_SERVICE=qwc-db-auth
git_version=$(git ls-remote https://github.com/qwc-services/$AUTH_SERVICE HEAD | cut -f 1)
git_versions['qwc-auth-service']=$git_version
docker-compose build --build-arg GIT_VERSION=$git_version qwc-auth-service
printf "\n================================================================================\n"

printf "\nUpdated containers:\n\n"
for ctr in ${!git_versions[@]}; do
  printf "${git_versions[$ctr]}  ${YELLOW}$ctr${NC}\n"
done
