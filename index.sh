#!/usr/bin/env bash
set -e

if [ ! -d "best-practices" ]
then
    git clone git@github.com:camunda/best-practices.git best-practices
fi
mkdir -p indexes
rm -rf indexes/*
cd best-practices
git fetch --all --prune

for b in `git branch --remote | awk -F ' +' '! /\(no branch\)/ {print $2}'`; do
  BRANCH=${b##*/}
  if [ ${BRANCH} != "HEAD" ]
  then
      git checkout -B ${BRANCH} $b
      if [ ${BRANCH} != "master" ]
      then
        sed -i -- "s/camunda\.com\/best-practices/camunda\.com\/best-practices-branch\/${BRANCH}/g" config.yaml
      fi
      grep "^\s*draft:\s*true\s*$" ./best-practices/content --include="index.adoc" -Rl | xargs rm $1
      hugoidx
      mv search.bleve "../indexes/${BRANCH}"
      rm -rf search.bleve
      git checkout .
      git clean -f
  fi
done

cd -
