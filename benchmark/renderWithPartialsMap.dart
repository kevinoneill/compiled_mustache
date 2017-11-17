import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:compiled_mustache/compiled_mustache.dart';

var noVars = compile(new File('./benchmark/helper/noVars.mustache').readAsStringSync());
var small  = compile(new File('./benchmark/helper/small-partials.mustache' ).readAsStringSync());
var large  = compile(new File('./benchmark/helper/large-partials.mustache' ).readAsStringSync());
var giant  = compile(new File('./benchmark/helper/giant-partials.mustache' ).readAsStringSync());

class NoPartialsBenchmark extends BenchmarkBase {
  const NoPartialsBenchmark() : super("NoPartials");
  
  void run() {
    var out = noVars.render({}, {});
  }
}

class SmallPartialsBenchmark extends BenchmarkBase {
  const SmallPartialsBenchmark() : super("SmallPartials");
  
  void run() {
    var out = small.render({}, {'item': 'a thing!'});
  }
}

class LargePartialsBenchmark extends BenchmarkBase {
  const LargePartialsBenchmark() : super("LargePartials");
  
  void run() {
    var out = large.render({ //vars
      
    }, { // partials
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

class GiantPartialsBenchmark extends BenchmarkBase {
  const GiantPartialsBenchmark() : super("GiantPartials");
  
  void run() {
    var out = giant.render({ //vars
      
    }, { // partials
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
  new NoPartialsBenchmark().report();
  new SmallPartialsBenchmark().report();
  new LargePartialsBenchmark().report();
  new GiantPartialsBenchmark().report();
}