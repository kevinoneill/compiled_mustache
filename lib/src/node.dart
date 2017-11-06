part of handlebars4dart;

class _Node {
  _NodeType type;
  
  String _text;
  String _name;
  List<_Node> _contents;
  
  HtmlEscape _escaper = new HtmlEscape();
  
  _Node(String from, _NodeType this.type, [List<_Node> this._contents]) {
    switch (type) {
      case _NodeType.text:
        _text = from;
        break;
      default:
        _name = from;
        break;
    }
  }
  
  String render(_Context cntxt) {
    switch (type) {
      case _NodeType.text: return _text;
      case _NodeType.interpolation: return _escaper.convert(cntxt.get(_name));
      case _NodeType.raw:
        print(_name);
        return cntxt.get(_name);
      case _NodeType.comment: return '';  //TODO: ignore comments during compile step
      default: return "\$";
    }
  }
}

enum _NodeType {
  text,
  interpolation,
  raw,
  comment,
  delimiter,
  section,
  inverted
}