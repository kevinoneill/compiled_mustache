import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:compiled_mustache/compiled_mustache.dart' show compile;

var noVars = new File('./benchmark/helper/noVars.mustache').readAsStringSync();
var small  = new File('./benchmark/helper/small-vars.mustache' ).readAsStringSync();
var large  = new File('./benchmark/helper/large-vars.mustache' ).readAsStringSync();
var giant  = new File('./benchmark/helper/giant-vars.mustache' ).readAsStringSync();

class CompileNoVarsBenchmark extends BenchmarkBase {
  const CompileNoVarsBenchmark() : super("CompileNoVars");
  
  void run() {
    var ct = compile(noVars).render({}, {});
  }
}

class CompileAndRenderSmallBenchmark extends BenchmarkBase {
  const CompileAndRenderSmallBenchmark() : super("CompileAndRenderSmall");
  
  void run() {
    var ct = compile(small).render({'item': 'a thing!'}, {});
  }
}

class CompileAndRenderLargeBenchmark extends BenchmarkBase {
  const CompileAndRenderLargeBenchmark() : super("CompileAndRenderLarge");
  
  void run() {
    var ct = compile(large).render({ //vars
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

class CompileAndRenderGiantBenchmark extends BenchmarkBase {
  const CompileAndRenderGiantBenchmark() : super("CompileAndRenderGiant");
  
  void run() {
    var ct = compile(giant).render({ //vars
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
  new CompileNoVarsBenchmark().report();
  new CompileAndRenderSmallBenchmark().report();
  new CompileAndRenderLargeBenchmark().report();
  new CompileAndRenderGiantBenchmark().report();
}