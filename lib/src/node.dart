part of compiled_mustache;

class _Node {
  static final HtmlEscape _escaper = new HtmlEscape();
  
  final _NodeType _type;
  
  final String _data;
  final List<_Node> _contents;
  final String _indent;
  
  bool _recursivePartal = false;
  
  _Node(String this._data, _NodeType this._type, [List<_Node> this._contents, String this._indent]);
  
  String render(_Context cntxt, CompiledTemplate partialProvider(String name), String indent) {
    return (_render(cntxt, partialProvider, indent) ?? '').toString();
  }
  
  Object _render(_Context cntxt, CompiledTemplate partialProvider(String name), String indent) {
    switch (_type) {
      case _NodeType.text: return _data.replaceAll('\n', '\n$indent');
      
      case _NodeType.interpolation: return _escaper.convert((cntxt.get(_data) ?? '').toString());
      case _NodeType.raw:           return cntxt.get(_data);
      
      case _NodeType.section:  return _renderSection(cntxt, partialProvider, indent);
      case _NodeType.inverted: return _renderInvertedSection(cntxt, partialProvider, indent);
      
      case _NodeType.partial: return partialProvider(_data)?._render(cntxt, partialProvider, indent + (_indent ?? ''));
      
      // Comments and Delimiter changes shouldn't be rendered.
      case _NodeType.delimiter: return '';
      case _NodeType.comment:   return '';
      
      // If none of the above types match, do nothing.
      default: return '';
    }
  }
  
  String _renderSection(_Context context, CompiledTemplate partialProvider(String name), String indent) {
    _Context cntxt = context.subContext(_data);
    if (cntxt == null || (cntxt._map == null && !_isTruthy(cntxt.get('.')))) {
      return '';
    }
    
    if (cntxt.get('.') is List<Object>) {
      return _renderSectionList(cntxt, partialProvider, indent);
    } else {
      return _renderSectionObj(cntxt, partialProvider, indent);
    }
  }
  
  String _renderSectionObj(_Context cntxt, CompiledTemplate partialProvider(String name), String indent) {
    String s = '';
    for (_Node n in _contents) {
      s += n.render(cntxt, partialProvider, indent);
    }
    return s;
  }
  
  String _renderSectionList(_Context context, CompiledTemplate partialProvider(String name), String indent) {
    String s = '';
    List<Object> l = context.get('.');
    for (Object o in l) {
      _Context cntxt = new _Context(o, context);
      s += _renderSectionObj(cntxt, partialProvider, indent);
    }
    return s;
  }
  
  String _renderInvertedSection(_Context cntxt, CompiledTemplate partialProvider(String name), String indent) {
    Object o = cntxt.get(_data);
    if (_isTruthy(o)) {
      return '';
    }
    
    String s = '';
    for (_Node n in _contents) {
      s += n.render(cntxt, partialProvider, indent);
    }
    return s;
  }
  
  bool _isTruthy(Object o) {
    if (o == null) return false;
    if (o is bool) return o;
    if (o is List) return o.isNotEmpty;
    if (o is Map)  return o.isNotEmpty;
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
    case '&': return _NodeType.raw;        // Raw interpolation (no escape).
    case '!': return _NodeType.comment;    // Comment.
    case '=': return _NodeType.delimiter;  // New delimiter.
    case '>': return _NodeType.partial;    // Partial.
    case '#': return _NodeType.section;    // Section start.
    case '^': return _NodeType.inverted;   // Inverted section start.
    case '/': return _NodeType.sectionEnd; // Section end.
  }
  return _NodeType.interpolation;
}

enum _NodeType {
  text, // Raw text.
  
  interpolation, // Interpolated var (escaped).
  raw,           // Interpolated var (not escaped).
  
  section,    // Block section.
  inverted,   // Inverted section.
  sectionEnd, // End of section.
  
  partial, // Partial.
  
  // Not rendered:
  delimiter,
  comment
}