#!/bin/bash
ENVIRONMENTPATH=$1
# $ENVIRONMENTPATH may contain multiple colon-delimited locations.
# We need to pick the first one that contains $ENVIRONMENT.
IFS=":"
for CANDIDATEPATH in ${ENVIRONMENTPATH}; do
  if [ -d "${CANDIDATEPATH}/${2}" ]; then
    ENVIRONMENTPATH=$CANDIDATEPATH
    break
  fi
done

if [ -e "${ENVIRONMENTPATH}/$2/.r10k-deploy.json" ]
then
  /opt/puppetlabs/puppet/bin/ruby "${ENVIRONMENTPATH}/$2/scripts/code_manager_config_version.rb" ${ENVIRONMENTPATH} $2
elif [ -e /opt/puppetlabs/server/pe_version ]
then
  /opt/puppetlabs/puppet/bin/ruby "${ENVIRONMENTPATH}/$2/scripts/config_version.rb" ${ENVIRONMENTPATH} $2
else
  /usr/bin/git --version > /dev/null 2>&1 &&
  /usr/bin/git --git-dir "${ENVIRONMENTPATH}/$2/.git" rev-parse HEAD ||
  date +%s
fi
