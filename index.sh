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
      hugoidx
      bleve_export search.bleve "../indexes/${b##*/}.export"
      rm -rf search.bleve
  fi
done

cd -
