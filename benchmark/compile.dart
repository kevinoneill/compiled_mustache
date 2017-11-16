import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:compiled_mustache/compiled_mustache.dart' show compile;

var noVars          = new File('./benchmark/helper/noVars.mustache'        ).readAsStringSync();
var small_vars      = new File('./benchmark/helper/small-vars.mustache'    ).readAsStringSync();
var small_partials  = new File('./benchmark/helper/small-partials.mustache').readAsStringSync();
var large_vars      = new File('./benchmark/helper/large-vars.mustache'    ).readAsStringSync();
var large_partials  = new File('./benchmark/helper/large-partials.mustache').readAsStringSync();
var giant_vars      = new File('./benchmark/helper/giant-vars.mustache'    ).readAsStringSync();
var giant_partials  = new File('./benchmark/helper/giant-partials.mustache').readAsStringSync();

class NoVarsBenchmark extends BenchmarkBase {
  const NoVarsBenchmark() : super("NoVars");
  
  void run() {
    var ct = compile(noVars);
  }
}

class SmallVarsBenchmark extends BenchmarkBase {
  const SmallVarsBenchmark() : super("SmallVars");
  
  void run() {
    var ct = compile(small_vars);
  }
}

class SmallPartialsBenchmark extends BenchmarkBase {
  const SmallPartialsBenchmark() : super("SmallPartials");
  
  void run() {
    var ct = compile(small_partials);
  }
}

class LargeVarsBenchmark extends BenchmarkBase {
  const LargeVarsBenchmark() : super("LargeVars");
  
  void run() {
    var ct = compile(large_vars);
  }
}

class LargePartialsBenchmark extends BenchmarkBase {
  const LargePartialsBenchmark() : super("LargePartials");
  
  void run() {
    var ct = compile(large_partials);
  }
}

class GiantVarsBenchmark extends BenchmarkBase {
  const GiantVarsBenchmark() : super("GiantVars");
  
  void run() {
    var ct = compile(giant_vars);
  }
}

class GiantPartialsBenchmark extends BenchmarkBase {
  const GiantPartialsBenchmark() : super("GiantPartials");
  
  void run() {
    var ct = compile(giant_partials);
  }
}

main() {
  new NoVarsBenchmark().report();
  new SmallVarsBenchmark().report();
  new SmallPartialsBenchmark().report();
  new LargeVarsBenchmark().report();
  new LargePartialsBenchmark().report();
  new GiantVarsBenchmark().report();
  new GiantPartialsBenchmark().report();
}