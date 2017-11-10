part of compiled_mustache;

/// Compile a string template into a [CompiledTemplate]
CompiledTemplate compile(String tmplt) {
  _Parser p = new _Parser(tmplt);
  List<_Node> nodes = p.parse();
  return new CompiledTemplate._internal(nodes);
}