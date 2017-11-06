import 'dart:io';
import 'package:handlebars4dart/handlebars4dart.dart' show compile;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  print(Directory.current.path + '/test/specs/comments.yml');
  
  var specs = new Directory('test/specs').listSync();
  for (FileSystemEntity file in specs) {
    if (file is File && path.extension(file.path) == ".yml") {
      String name = path.basenameWithoutExtension(file.path);
      
      if (name == 'comments' || name == 'interpolation') {
        YamlNode spec = loadYaml((file as File).readAsStringSync());
        runSpec(name, spec);
      }
    }
  }
  
  var comments = loadYaml(new File('test/specs/comments.yml').readAsStringSync());
  
  // .then((String contents) {
  //   console.log(contents);
  //   var doc = loadYaml(contents);
  //   print(doc['overview']);
  // }).catchError((error) => print(error));
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