part of compiled_mustache;

CompiledTemplate compile(String tmplt) {
  _Parser p = new _Parser(tmplt);
  List<_Node> nodes = p.parse();
  return new CompiledTemplate(nodes);
}