#!/bin/bash

set -ev

git clone https://github.com/thislooksfun/compiled_mustache.wiki.git
grind doc_benchmark_wiki
cd compiled_mustache.wiki
git add -A
git commit -m "Update Benchmarks"
git push

# pub publish --dry-run