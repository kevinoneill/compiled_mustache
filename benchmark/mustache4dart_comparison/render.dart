import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:mustache4dart/mustache4dart.dart' show render;

var noVars = new File('./benchmark/helper/noVars.mustache'    ).readAsStringSync();
var small  = new File('./benchmark/helper/small-vars.mustache').readAsStringSync();
var large  = new File('./benchmark/helper/large-vars.mustache').readAsStringSync();
var giant  = new File('./benchmark/helper/giant-vars.mustache').readAsStringSync();

class NoVarsBenchmark extends BenchmarkBase {
  const NoVarsBenchmark() : super("NoVars");
  
  void run() {
    var out = render(noVars, {});
  }
}

class SmallVarsBenchmark extends BenchmarkBase {
  const SmallVarsBenchmark() : super("SmallVars");
  
  void run() {
    var out = render(small, {'item': 'a thing!'});
  }
}

class LargeVarsBenchmark extends BenchmarkBase {
  const LargeVarsBenchmark() : super("LargeVars");
  
  void run() {
    var out = render(large, { //vars
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
    });
  }
}

class GiantVarsBenchmark extends BenchmarkBase {
  const GiantVarsBenchmark() : super("GiantVars");
  
  void run() {
    var out = render(giant, { //vars
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
    });
  }
}

main() {
  new NoVarsBenchmark().report();
  new SmallVarsBenchmark().report();
  new LargeVarsBenchmark().report();
  new GiantVarsBenchmark().report();
}