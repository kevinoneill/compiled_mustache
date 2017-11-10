import 'package:compiled_mustache/compiled_mustache.dart' show compile, CompiledTemplate;

var ct = compile('{{> greeting}}');

var greeting = compile('Hello, {{name}}!');

ct.render({'name': 'world'}, {'greeting': greeting});  // Hello, world!
ct.render({'name': 'Dart'},  {'greeting': greeting});  // Hello, Dart!