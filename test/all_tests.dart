import 'dart:io';
import 'package:handlebars4dart/handlebars4dart.dart' show compile;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  var specs = new Directory('test/specs').listSync();
  for (FileSystemEntity file in specs) {
    if (file is File && path.extension(file.path) == ".yml") {
      String name = path.basenameWithoutExtension(file.path);
      
      if (name == 'sections' || name == 'comments' || name == 'interpolation' || name == 'inverted') {
      // if (name == '~lambdas') {
      // if (name == 'comments') {
      // if (name == 'delimiters') {
      // if (name == 'interpolation') {
      // if (name == 'inverted') {
      // if (name == 'partials') {
      // if (name == 'sections') {
        YamlNode spec = loadYaml((file as File).readAsStringSync());
        runSpec(name, spec);
      }
    }
  }
  
  // String tmplt = """{{#a}}
  // {{one}}
  // {{#b}}
  // {{one}}{{two}}{{one}}
  // {{#c}}
  // {{one}}{{two}}{{three}}{{two}}{{one}}
  // {{#d}}
  // {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
  // {{#e}}
  // {{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
  // {{/e}}
  // {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
  // {{/d}}
  // {{one}}{{two}}{{three}}{{two}}{{one}}
  // {{/c}}
  // {{one}}{{two}}{{one}}
  // {{/b}}
  // {{one}}
  // {{/a}}""";
  
  // String tmplt = """{{#a}}
  // {{one}}
  // {{#b}}
  // {{one}}{{two}}{{one}}
  // {{/b}}
  // {{one}}
  // {{/a}}""";
  //
  // Map<String, Object> map = {
  //   'a': { 'one': 1 },
  //   'b': { 'two': 2 },
  //   'c': { 'three': 3 },
  //   'd': { 'four': 4 },
  //   'e': { 'five': 5 }
  // };
  //
  // print(tmplt);
  // print('------------');
  // print(compile(tmplt).render(map));
}

void runSpec(String name, YamlNode spec) {
  group(name, () {
    YamlNode tests = spec['tests'];
    for (YamlNode test in tests) {
      runTest(test);
    }
    // runTest(tests[3]);
  });
}

void runTest(YamlNode t) {
  test(t['name'], () {
    String r = compile(t['template']).render(t['data'].value);
    expect(r, equals(t['expected']));
  });
}