#!/bin/bash

set -ev

# git clone https://github.com/thislooksfun/compiled_mustache.wiki.git
# grind doc_benchmark_wiki
# cd compiled_mustache.wiki
# git add -A
# git commit -m "Update Benchmarks"
# git push

# If it already exists, clean it out
if [ -d "deploy_staging" ]; then
  rm -rf "deploy_staging"
fi

mkdir "deploy_staging"

function cp_dep() {
  if [ -d "$1" ]; then
    cp -r "$1" "deploy_staging/$1"
  else
    cp "$1" "deploy_staging/"
  fi
}

# Folders
cp_dep "benchmark"
cp_dep "doc"
cp_dep "example"
cp_dep "lib"
cp_dep "test"

# Files
cp_dep ".gitignore"
cp_dep ".gitmodules"
cp_dep "CHANGELOG.md"
cp_dep "LICENSE"
cp_dep "pubspec.yaml"
cp_dep "README.md"

cd "deploy_staging"

# TODO: Hide scripts/ and tool/ directories before running this
# pub publish --dry-run