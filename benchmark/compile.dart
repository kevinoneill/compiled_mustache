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

class CompileNoVarsBenchmark extends BenchmarkBase {
  const CompileNoVarsBenchmark() : super("CompileNoVars");
  
  void run() {
    var ct = compile(noVars);
  }
}

class CompileSmallVarsBenchmark extends BenchmarkBase {
  const CompileSmallVarsBenchmark() : super("CompileSmallVars");
  
  void run() {
    var ct = compile(small_vars);
  }
}

class CompileSmallPartialsBenchmark extends BenchmarkBase {
  const CompileSmallPartialsBenchmark() : super("CompileSmallPartials");
  
  void run() {
    var ct = compile(small_partials);
  }
}

class CompileLargeVarsBenchmark extends BenchmarkBase {
  const CompileLargeVarsBenchmark() : super("CompileLargeVars");
  
  void run() {
    var ct = compile(large_vars);
  }
}

class CompileLargePartialsBenchmark extends BenchmarkBase {
  const CompileLargePartialsBenchmark() : super("CompileLargePartials");
  
  void run() {
    var ct = compile(large_partials);
  }
}

class CompileGiantVarsBenchmark extends BenchmarkBase {
  const CompileGiantVarsBenchmark() : super("CompileGiantVars");
  
  void run() {
    var ct = compile(giant_vars);
  }
}

class CompileGiantPartialsBenchmark extends BenchmarkBase {
  const CompileGiantPartialsBenchmark() : super("CompileGiantPartials");
  
  void run() {
    var ct = compile(giant_partials);
  }
}

main() {
  new CompileNoVarsBenchmark().report();
  new CompileSmallVarsBenchmark().report();
  new CompileSmallPartialsBenchmark().report();
  new CompileLargeVarsBenchmark().report();
  new CompileLargePartialsBenchmark().report();
  new CompileGiantVarsBenchmark().report();
  new CompileGiantPartialsBenchmark().report();
}