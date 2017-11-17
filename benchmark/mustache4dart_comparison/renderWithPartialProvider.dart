import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:mustache4dart/mustache4dart.dart' show render;

var noVars = new File('./benchmark/helper/noVars.mustache').readAsStringSync();
var small  = new File('./benchmark/helper/small-partials.mustache' ).readAsStringSync();
var large  = new File('./benchmark/helper/large-partials.mustache' ).readAsStringSync();
var giant  = new File('./benchmark/helper/giant-partials.mustache' ).readAsStringSync();

var partials = {
  'item': 'a thing!',
  'app-todo-css': 'asdf',
  'app-todo-html': 'fdsa',
  'app-todo-templates': 'weee!',
  'app-todo-js': 'hmm',
  'js-yui-seed': 'seedy indeed',
  'app-todo-js-yui-start': 'start \'er up!',
  'app-todo-js-yui-end': 'aww, it\'s over',
  'app-todo-js-todo': 'well',
  'app-todo-js-todolist': 'oejfoajf',
  'app-todo-js-app-view': 'jfohofha',
  'app-todo-js-todo-view': 'view(port)',
  'app-todo-js-localstorage-sync': 'LOCAL',
  'app-todo-js-init': 'initalizing...'
};

var pp = (String n) => partials[n];

class NoVarsBenchmark extends BenchmarkBase {
  const NoVarsBenchmark() : super("NoPartials");
  
  void run() {
    var ct = render(noVars, {}, partial: pp);
  }
}

class SmallBenchmark extends BenchmarkBase {
  const SmallBenchmark() : super("SmallPartials");
  
  void run() {
    var ct = render(small, {}, partial: pp);
  }
}

class LargeBenchmark extends BenchmarkBase {
  const LargeBenchmark() : super("LargePartials");
  
  void run() {
    var ct = render(large, {}, partial: pp);
  }
}

class GiantBenchmark extends BenchmarkBase {
  const GiantBenchmark() : super("GiantPartials");
  
  void run() {
    var ct = render(giant, {}, partial: pp);
  }
}

main() {
  new NoVarsBenchmark().report();
  new SmallBenchmark().report();
  new LargeBenchmark().report();
  new GiantBenchmark().report();
}