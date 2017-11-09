part of compiled_mustache;

CompiledTemplate compile(String tmplt) {
  _Parser p = new _Parser(tmplt);
  List<_Node> nodes = p.parse();
  return new CompiledTemplate(nodes);
}

CompiledTemplate compileWithPartials(String tmplt, Map<String, Object> partials) {
  _Parser p = new _Parser(tmplt);
  List<_Node> nodes = p.parse();
  return new CompiledTemplate(nodes).compileWithPartials(partials);
}

CompiledTemplate compileWithPartialProvider(String tmplt, CompiledTemplate partialProvider(String name)) {
  _Parser p = new _Parser(tmplt);
  List<_Node> nodes = p.parse();
  return new CompiledTemplate(nodes).compileWithPartialProvider(partialProvider);
}