compiled_mustache
=================

This is a lightweight [mustache](https://mustache.github.io) renderer for Dart. It is [2.008-15.036x faster](doc/benchmarks/comparison.md) than mustache4dart, and provides the ability to cache parsed templates to avoid having to read from disk and parse files on every render.