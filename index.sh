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
  if [ ${b##*/} != "HEAD" ]
  then
      git checkout -B ${b##*/} $b
      if [ ${b##*/} != "master" ]
      then
        sed -i -- "s/camunda\.com\/best-practices/camunda\.com\/best-practices-branch\/${b##*\/}/g" config.yaml
      fi
      hugoidx
      mv search.bleve "../indexes/${b##*/}"
      rm -rf search.bleve
      git checkout .
      git clean -f
  fi
done

cd -
