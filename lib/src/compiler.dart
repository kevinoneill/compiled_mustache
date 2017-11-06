part of handlebars4dart;

_CompiledTemplate compile(String tmplt) {
  _Parser p = new _Parser(tmplt);
  List<_Node> nodes = p.parse();
  return new _CompiledTemplate(nodes);
}