import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:compiled_mustache/compiled_mustache.dart';

var noVars = compile(new File('./benchmark/helper/noVars.mustache').readAsStringSync());
var small  = compile(new File('./benchmark/helper/small-partials.mustache' ).readAsStringSync());
var large  = compile(new File('./benchmark/helper/large-partials.mustache' ).readAsStringSync());
var giant  = compile(new File('./benchmark/helper/giant-partials.mustache' ).readAsStringSync());

class RenderNoVarsBenchmark extends BenchmarkBase {
  const RenderNoVarsBenchmark() : super("RenderNoVars");
  
  void run() {
    var out = noVars.render({}, {});
  }
}

class RenderSmallPartialsBenchmark extends BenchmarkBase {
  const RenderSmallPartialsBenchmark() : super("RenderSmallPartials");
  
  void run() {
    var out = small.render({}, {'item': 'a thing!'});
  }
}

class RenderLargePartialsBenchmark extends BenchmarkBase {
  const RenderLargePartialsBenchmark() : super("RenderLargePartials");
  
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

class RenderGiantPartialsBenchmark extends BenchmarkBase {
  const RenderGiantPartialsBenchmark() : super("RenderGiantPartials");
  
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
  new RenderNoVarsBenchmark().report();
  new RenderSmallPartialsBenchmark().report();
  new RenderLargePartialsBenchmark().report();
  new RenderGiantPartialsBenchmark().report();
}