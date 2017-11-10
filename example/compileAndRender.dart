import 'package:compiled_mustache/compiled_mustache.dart' show compile, CompiledTemplate;

var ct = compile('Hello, {{name}}!');

ct.render({'name': 'world'}, {});  // Hello, world!
ct.render({'name': 'Dart'}, {});   // Hello, Dart!