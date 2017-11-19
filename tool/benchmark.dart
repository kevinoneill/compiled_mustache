import 'dart:io';
import 'dart:math';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as pathPackage;
import 'package:yaml/yaml.dart';

const _comparisons = const [
  const {
    'msg': 'Combined compile *and* render time',
    'pairs': const {
      'compileAndRender': 'render',
      'compileAndRenderWithPartialProvider': 'renderWithPartialProvider'
    }
  },
  const {
    'msg': 'Compare compiled_mustache\'s render function vs mustache4dart\'s.\n'
           'compile_mustache has the option to compile and cache a template, then render it later.\n'
           'This compares that functionality vs the less cacheable render function provided by mustache4dart',
    'pairs': const {
      'render': 'render',
      'renderWithPartialProvider': 'renderWithPartialProvider'
    }
  }
];

Future _forEachBenchmark(String path, void preProcess(String), void postProcess(String, ProcessResult)) async {
  var benchmarks = await new Directory(pathPackage.join('benchmark', path)).listSync();
  var first = true;
  for (var file in benchmarks) {
    if (file is File && pathPackage.extension(file.path) == ".dart") {
      String fileName = pathPackage.basename(file.path);
      String name = pathPackage.basenameWithoutExtension(fileName);
      
      preProcess(name);
      ProcessResult results = await Process.run('dart', [pathPackage.join('benchmark', path, fileName)]);
      postProcess(name, results);
    }
  }
}


Future runBenchmarks() async {
  Map<String, double> processOutput(String o) {
    var trimmed = o;
    
    //remove trailing newlines
    while (trimmed[trimmed.length-1] == '\n') {
      trimmed = trimmed.substring(0, trimmed.length-1);
    }
    
    Map<String, double> tests = {};
    for (var l in trimmed.split('\n')) {
      var parts = l.split('(RunTime): ');
      tests[parts[0]] = _parseTime(parts[1]);
    }
    
    return tests;
  }
  
  var cmBenchmarks = await _runCMBenchmarks(processOutput);
  log('');
  var m4dBenchmarks = await _runM4DBenchmarks(processOutput);
  
  
  
  _compareBenchmarks(cmBenchmarks, m4dBenchmarks);
}

Future<Map<String, Map<String, double>>> _runCMBenchmarks(Map<String, double> processOutput(String)) async {
  Map<String, Map<String, double>> benchmarks = {};
  log('Running compiled_mustache benchmarks...');
  await _forEachBenchmark('', (String name) {
    log('  $name');
  }, (String name, ProcessResult pr) {
    var res = pr.stdout.toString();
    benchmarks[name] = processOutput(res);
    log('    ${res.replaceAll('\n', '\n    ')}');
  });
  return benchmarks;
}

Future<Map<String, Map<String, double>>> _runM4DBenchmarks(Map<String, double> processOutput(String)) async {
  Map<String, Map<String, double>> benchmarks = {};
  log('Running mustache4dart benchmarks...');
  await _forEachBenchmark('mustache4dart_comparison', (String name) {
    log('  $name');
  }, (String name, ProcessResult pr) {
    var res = pr.stdout.toString();
    benchmarks[name] = processOutput(res);
    log('    ${res.replaceAll('\n', '\n    ')}');
  });
  return benchmarks;
}

void _compareBenchmarks(Map<String, Map<String, double>> compiled_mustache_results, Map<String, Map<String, double>> mustache4dart_results) {
  log('\n> Comparing benchmarks...');
  for (var group in _comparisons) {
    var pairs = group['pairs'];
    for (var n in pairs.keys) {
      log('    $n');
      var cmSuite = compiled_mustache_results[n];
      var m4dSuite = mustache4dart_results[pairs[n]];
      
      for (var k in cmSuite.keys) {
        var cm  = cmSuite[k];
        var m4d = m4dSuite[k];
        
        var tooSlow = cm > m4d;
        
        log('      Comparing $k ($cm vs $m4d) : ${!tooSlow}');
        
        if (tooSlow) {
          exitCode = 1;
        }
      }
    }
  }
  
}

String _repeatStr(String s, int times) {
  String o = '';
  for (var i = 0; i < times; i++) {
    o += s;
  }
  return o;
}

double _parseTime(String s) {
  var trimmed = s.substring(0, s.length-4);
  return double.parse(trimmed);
}

String _formatTime(String s, int ensurePlaces) {
  var trimmed = s.substring(0, s.length-4); // remove ' us.' from end
  var dotIndex = trimmed.indexOf('.');
  if (dotIndex == -1) {
    return trimmed + '.' + _repeatStr('0', ensurePlaces);
  }
  
  var fromEnd = trimmed.length - dotIndex - 1;
  if (fromEnd > ensurePlaces) {
    return trimmed.substring(0, trimmed.length - (fromEnd - ensurePlaces));
  } else if (fromEnd < ensurePlaces) {
    return trimmed + _repeatStr('0', ensurePlaces - fromEnd);
  }
  
  return trimmed;
}

Future documentBenchmarks() async {
  log('\nGenerating benchmarks.md...');
  // Document benchmark results
  Map<String, Map<String, String>> compiled_mustache_results = {};
  Map<String, Map<String, String>> mustache4dart_results = {};
  
  Map<String, String> processOutput(String o) {
    var trimmed = o;
    
    //remove trailing newlines
    while (trimmed[trimmed.length-1] == '\n') {
      trimmed = trimmed.substring(0, trimmed.length-1);
    }
    
    Map<String, String> tests = {};
    for (var l in trimmed.split('\n')) {
      var parts = l.split('(RunTime): ');
      tests[parts[0]] = _formatTime(parts[1], 8);
    }
    
    return tests;
  }
  
  
  
  log('  Running compiled_mustache benchmarks...');
  await _forEachBenchmark('', (String name) {
    log('    $name');
  }, (String name, ProcessResult pr) {
    compiled_mustache_results[name] = processOutput(pr.stdout.toString());
  });
  
  log('  Running mustache4dart benchmarks...');
  await _forEachBenchmark('mustache4dart_comparison', (String name) {
    log('    $name');
  }, (String name, ProcessResult pr) {
    mustache4dart_results[name] = processOutput(pr.stdout.toString());
  });
  
  // Generate docs
  await _documentCompiledMustache(compiled_mustache_results);
  await _documentMustache4Dart(mustache4dart_results);
  await _documentComparison(compiled_mustache_results, mustache4dart_results);
}

Future _documentCompiledMustache(Map<String, Map<String, String>> results) async {
  YamlNode pubspec = loadYaml((await new File('pubspec.yaml')).readAsStringSync());
  var cmver = pubspec['version'];
  String contents =
    '<!-- THIS FILE IS AUTOGENERATED BY \'grind doc\'; DO NOT MODIFY -->\n\n'
    'Benchmarks for compiled_mustache v$cmver\n'
    '========================================\n';
  
  for (var n in results.keys) {
    var suite = results[n];
    
    contents += '\n\n## $n\n';
    contents += '|Name|Time (in μs)|\n';
    contents += '|----|-----------:|'; //don't end with newline because the loop below takes care of that
    
    for (var k in suite.keys) {
      contents += '\n|$k|`${suite[k]}`|';
    }
  }
  
  await _writeToDocFile('compiled_mustache', contents);
}

Future _documentMustache4Dart(Map<String, Map<String, String>> results) async {
  YamlNode pubspecLock = loadYaml((await new File('pubspec.lock')).readAsStringSync());
  var m4dver = pubspecLock['packages']['mustache4dart']['version'];
  String contents =
    '<!-- THIS FILE IS AUTOGENERATED BY \'grind doc\'; DO NOT MODIFY -->\n\n'
    'Benchmarks for mustache4dart v$m4dver\n'
    '=====================================\n';
  
  for (var n in results.keys) {
    var suite = results[n];
    
    contents += '\n\n## $n\n';
    contents += '|Name|Time (in μs)|\n';
    contents += '|----|-----------:|'; //don't end with newline because the loop below takes care of that
    
    for (var k in suite.keys) {
      contents += '\n|$k|`${suite[k]}`|';
    }
  }
  
  await _writeToDocFile('mustache4dart', contents);
}

Future _documentComparison(Map<String, Map<String, String>> compiled_mustache_results, Map<String, Map<String, String>> mustache4dart_results) async {
  YamlNode pubspec = loadYaml((await new File('pubspec.yaml')).readAsStringSync());
  var cmver = pubspec['version'];
  YamlNode pubspecLock = loadYaml((await new File('pubspec.lock')).readAsStringSync());
  var m4dver = pubspecLock['packages']['mustache4dart']['version'];
  
  String title =
    '<!-- THIS FILE IS AUTOGENERATED BY \'grind doc\'; DO NOT MODIFY -->\n\n'
    'Comparison of compiled_mustache v$cmver and mustache4dart v$m4dver\n'
    '==================================================================\n';
  
  String contents = '';
  var minDiff = double.MAX_FINITE;
  var maxDiff = 0;
  var avgSum = 0;
  var totalCount = 0;
  
  for (var group in _comparisons) {
    contents += '\n-----\n# ${group['msg']}';
    
    var pairs = group['pairs'];
    for (var n in pairs.keys) {
      var cmSuite = compiled_mustache_results[n];
      var m4dSuite = mustache4dart_results[pairs[n]];
      
      contents += '\n\n### [$n](compiled_mustache.md#${n.toString().toLowerCase()}) vs [${pairs[n]}](mustache4dart.md#${pairs[n].toString().toLowerCase()})\n';
      contents += '|Name|compiled_mustache time (in μs)|mustache4dart time (in μs)|Difference factor|\n';
      contents += '|----|-----------------------------:|-------------------------:|----------------:|'; //don't end with newline because the loop below takes care of that
      
      for (var k in cmSuite.keys) {
        var diff = double.parse(m4dSuite[k])/double.parse(cmSuite[k]);
        if (diff < minDiff) {
          minDiff = diff;
        }
        if (diff > maxDiff) {
          maxDiff = diff;
        }
        avgSum += diff;
        totalCount++;
        var formattedDiff = _formatTime('$diff', 3);
        contents += '\n|$k|`${cmSuite[k]}`|`${m4dSuite[k]}`|`${formattedDiff}x`|';
      }
    }
  }
  
  var avg = avgSum/totalCount;
  
  var avgStr     = _formatTime('$avg',     3);
  var minDiffStr = _formatTime('$minDiff', 3);
  var maxDiffStr = _formatTime('$maxDiff', 3);
  var toWrite = title + '\n\n## Results  \n**Average:** ${avgStr}x  \n**Minimum:** ${minDiffStr}x  \n**Maximum:** ${maxDiffStr}x\n' + contents;
  
  await _writeToDocFile('comparison', toWrite);
  await _updateReadme(minDiffStr, maxDiffStr);
}

Future _writeToDocFile(String name, String contents) async {
  var file = await new File('doc/benchmarks/$name.md');
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  file.writeAsString(contents);
}

Future _updateReadme(String minDiff, String maxdiff) async {
  var file = await new File('README.md');
  if (!file.existsSync()) {
    return;
  }
  String contents = file.readAsStringSync();
  contents = contents.replaceFirst(new RegExp(r'\[\d+\.\d+-\d+\.\d+x faster\]\(doc\/benchmarks\/comparison\.md\)'), '[$minDiff-${maxdiff}x faster](doc/benchmarks/comparison.md)');
  file.writeAsString(contents);
}