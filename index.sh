#!/usr/bin/env bash
set -e

if [ "$1" != "master" ] && [ "$1" != "branch" ]
then
    echo "index.sh master -> Index master excluding draft files"
    echo "index.sh branch -> Index all branches except of master including draft files"
    exit 0
fi

if [ ! -d "best-practices" ]
then
    git clone git@github.com:camunda/best-practices.git best-practices
fi
mkdir -p indexes
cd best-practices
git fetch --all --prune

if [ "$1" == "master" ]
then
  git checkout -B master origin/master
  grep "^\s*draft:\s*true\s*$" ./best-practices/content --include="index.adoc" -Rl | xargs rm $1
  rm -rf ../indexes/master
  hugoidx
  mv search.bleve "../indexes/master"
  rm -rf search.bleve
  git checkout .
  git clean -df
else
    for b in `git branch --remote | awk -F ' +' '! /\(no branch\)/ {print $2}'`; do
      BRANCH=${b##*/}
      if [ ${BRANCH} != "HEAD" ] && [ ${BRANCH} != "master" ]
      then
          git checkout -B ${BRANCH} $b
          sed -i -- "s/camunda\.com\/best-practices/camunda\.com\/best-practices-branch\/${BRANCH}/g" config.yaml
          rm -rf ../indexes/$BRANCH
          hugoidx
          mv search.bleve "../indexes/${BRANCH}"
          rm -rf search.bleve
          git checkout .
          git clean -f
      fi
    done
fi

cd -
