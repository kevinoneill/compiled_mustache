compiled_mustache
=================

This is a lightweight [mustache](https://mustache.github.io) renderer for Dart. It is [2.077-15.345x faster](doc/benchmarks/comparison.md)<sup>1</sup> than mustache4dart, and provides the ability to cache parsed templates to avoid having to read from disk and parse files on every render.


---

<sup>1</sup> These numbers are auto-generated while running `grind doc`, and are thus volatile and ballparks.