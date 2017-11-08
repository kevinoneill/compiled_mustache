part of handlebars4dart;

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