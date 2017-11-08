import 'dart:io';
import 'package:handlebars4dart/handlebars4dart.dart' show compile, CompiledTemplate;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  var specs = new Directory('test/specs').listSync();
  for (FileSystemEntity file in specs) {
    if (file is File && path.extension(file.path) == ".yml") {
      String name = path.basenameWithoutExtension(file.path);
      
      if (false
      //  || name == '~lambdas'
       || name == 'comments'      // Done
       || name == 'delimiters'    // Done
       || name == 'interpolation' // Done
       || name == 'inverted'      // Done
       || name == 'partials'      // Done
       || name == 'sections'      // Done
        ) {
        YamlNode spec = loadYaml((file as File).readAsStringSync());
        runSpec(name, spec);
      }
    }
  }
}

void runSpec(String name, YamlNode spec) {
  group(name, () {
    YamlNode tests = spec['tests'];
    
    for (YamlNode test in tests) {
      runTest(test);
    }
    
    // runTest(tests[2]);
  });
}

void runTest(YamlNode t) {
  test(t['name'], () {
    Map<String, Object> partials = t['partials']?.value;
    CompiledTemplate ct = compile(t['template']);
    if (partials != null) {
      ct = ct.compileWithPartials(partials);
    }
    String r = ct.render(t['data'].value);
    expect(r, equals(t['expected']));
  });
}