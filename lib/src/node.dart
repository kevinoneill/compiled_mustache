part of handlebars4dart;

class _Node {
  _NodeType type;
  
  String _text;
  String _name;
  List<_Node> _contents;
  
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
      case _NodeType.interpolation: return cntxt.get(_name);
      case _NodeType.comment: return '';  //TODO: ignore comments during compile step
      default: return "$type";
    }
  }
}

enum _NodeType {
  text,
  interpolation,
  comment,
  delimiter,
  section,
  inverted
}