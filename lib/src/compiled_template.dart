part of handlebars4dart;

class _CompiledTemplate {
  List<_Node> _nodes;
  
  _CompiledTemplate(List<_Node> this._nodes) {
  }
  
  String render(Map<String, Object> context) {
    _Context cntxt = new _Context(context);
    String s = "";
    for (_Node n in _nodes) {
      s += n.render(cntxt);
    }
    return s;
  }
}