import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:compiled_mustache/compiled_mustache.dart' show compile, CompiledTemplate;

var noVars = compile(new File('./benchmark/helper/noVars.mustache'    ).readAsStringSync());
var small  = compile(new File('./benchmark/helper/small-vars.mustache').readAsStringSync());
var large  = compile(new File('./benchmark/helper/large-vars.mustache').readAsStringSync());
var giant  = compile(new File('./benchmark/helper/giant-vars.mustache').readAsStringSync());

class RenderNoVarsBenchmark extends BenchmarkBase {
  const RenderNoVarsBenchmark() : super("RenderNoVars");
  
  void run() {
    var out = noVars.render({}, {});
  }
}

class RenderSmallVarsBenchmark extends BenchmarkBase {
  const RenderSmallVarsBenchmark() : super("RenderSmallVars");
  
  void run() {
    var out = small.render({'item': 'a thing!'}, {});
  }
}

class RenderLargeVarsBenchmark extends BenchmarkBase {
  const RenderLargeVarsBenchmark() : super("RenderLargeVars");
  
  void run() {
    var out = large.render({ //vars
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
    }, {});
  }
}

class RenderGiantVarsBenchmark extends BenchmarkBase {
  const RenderGiantVarsBenchmark() : super("RenderGiantVars");
  
  void run() {
    var out = giant.render({ //vars
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
    }, {});
  }
}

main() {
  new RenderNoVarsBenchmark().report();
  new RenderSmallVarsBenchmark().report();
  new RenderLargeVarsBenchmark().report();
  new RenderGiantVarsBenchmark().report();
}