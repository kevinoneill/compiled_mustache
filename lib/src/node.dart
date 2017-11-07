part of handlebars4dart;

class _Node {
  _NodeType type;
  
  String _data;
  List<_Node> _contents;
  
  HtmlEscape _escaper = new HtmlEscape();
  
  _Node(String this._data, _NodeType this.type, [List<_Node> this._contents]) {
  }
  
  String render(_Context cntxt) {
    return (_render(cntxt) ?? '').toString();
  }
  
  Object _render(_Context cntxt) {
    switch (type) {
      case _NodeType.text: return _data;
      
      case _NodeType.interpolation: return _escaper.convert((cntxt.get(_data) ?? '').toString());
      case _NodeType.raw:           return cntxt.get(_data);
      
      case _NodeType.section:  return _renderSection(cntxt);
      case _NodeType.inverted: return _renderInvertedSection(cntxt);
      
      // Comments and Delimiter changes shouldn't be rendered
      case _NodeType.delimiter: return '';
      case _NodeType.comment:   return '';
      
      // If none of the above types match, do nothing
      default: return '';
    }
  }
  
  String _renderSection(_Context context) {
    _Context cntxt = context.subContext(_data);
    if (cntxt == null || (cntxt._map == null && !_isTruthy(cntxt.get('.')))) {
      return '';
    }
    
    if (cntxt.get('.') is List<Object>) {
      return _renderSectionList(cntxt);
    } else {
      return _renderSectionObj(cntxt);
    }
  }
  
  String _renderSectionObj(_Context cntxt) {
    String s = '';
    for (_Node n in _contents) {
      s += n.render(cntxt);
    }
    return s;
  }
  
  String _renderSectionList(_Context context) {
    String s = '';
    List<Object> l = context.get('.');
    for (Object o in l) {
      _Context cntxt = new _Context(o, context);
      s += _renderSectionObj(cntxt);
    }
    return s;
  }
  
  String _renderInvertedSection(_Context cntxt) {
    Object o = cntxt.get(_data);
    if (_isTruthy(o)) {
      return '';
    }
    
    String s = '';
    for (_Node n in _contents) {
      s += n.render(cntxt);
    }
    return s;
  }
  
  bool _isTruthy(Object o) {
    if (o == null) return false;
    if (o is bool) return o;
    if (o is List) return o.length > 0;
    if (o is Map)  return o.length > 0;
    return true;
  }
}

_NodeType _nodeTypeFromChar(String c) {
  if (c.length == null) {
    throw new ArgumentError.notNull('c');
  }
  if (c.length != 1) {
    throw new StateError("Expected c to be 1 char, was actually ${c.length}");
  }
  
  switch (c) {
    case '&': return _NodeType.raw;       // raw interpolation (no escape)
    case '!': return _NodeType.comment;   // comment
    case '=': return _NodeType.delimiter; // new delimiter
    case '>': return _NodeType.partial;   // partial
    case '#': return _NodeType.section;   // section start
    case '^': return _NodeType.inverted;  // inverted section start
    case '/': return _NodeType.sectionEnd;// section end
  }
  return _NodeType.interpolation;
}

enum _NodeType {
  text, // Raw text
  
  interpolation, // Interpolated var (escaped)
  raw,           // Interpolated var (not escaped)
  
  section,    // Block section
  inverted,   // Inverted section
  sectionEnd, // End of section
  
  // Not rendered:
  delimiter,
  comment
}