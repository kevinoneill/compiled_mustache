import 'package:compiled_mustache/compiled_mustache.dart' show compile, CompiledTemplate;

var ct = compile('{{> greeting}}');

var greetings = [
  compile('Hello, {{name}}!'),
  compile('Howdy, {{name}}!')
]

int index = 0;
var partialProvider = CompiledTemplate (name) {
  if (name == 'greeting') {
    return greetings[index++];
  }
};

ct.renderWithPartialProvider({'name': 'world'}, partialProvider);  // Hello, world!
ct.renderWithPartialProvider({'name': 'Dart'},  partialProvider);  // Howdy, Dart!