part of handlebars4dart;

class _Parser {
  RegExp _anyChar = new RegExp(r'\S', multiLine: true);
  RegExp _newline = new RegExp(r'\n', multiLine: true);
  
  String _tmplt;
  
  int _nextStartIndex = 0;
  int _openIndex = 0;
  int _closeIndex = 0;
  bool _skipNode = false;
  
  _Delimiter _delim;
  
  List<_Node> _nodes = [];
  
  List<String> _nameStack = [];
  List<bool> _inversionStack = [];
  List<List<_Node>> _stack = [];
  
  _Parser(String this._tmplt) {
  }
  
  
  List<_Node> parse() {
    _delim = new _Delimiter();
    while (true) {
      _skipNode = false;
      if (_nextStartIndex >= _tmplt.length) {
        break;
      }
      _openIndex = _tmplt.indexOf(_delim.start, _nextStartIndex);
      if (_openIndex == -1) {
        break;
      }
      _closeIndex = _tmplt.indexOf(_delim.end, _openIndex + _delim.start.length);
      if (_closeIndex == -1) {
        break;
      }
      
      String name = _tmplt.substring(_openIndex + _delim.start.length, _closeIndex).trim();
      _NodeType type = _nodeTypeFromChar(name[0]);
      
      if (type == _NodeType.comment) {
        _skipNode = true;
        if (processStandaloneTag()) {
          // Comment was on it's own line, indicies have already been updated
          continue;
        }
      }
      
      if (!(isOnOwnLine() && ignoreOwnLined(type)) && _openIndex > 0) {
        // Capture the stuff before the tag
        _nodes.add(new _Node(_tmplt.substring(_nextStartIndex, _openIndex), _NodeType.text));
      }
      
      if (type == _NodeType.interpolation) {
        processInterpolation();
      } else {
        // If the type isn't a straight interpolation, it has an extra char at the beginning
        name = name.substring(1).trim();
      }
      
      if (type == _NodeType.section || type == _NodeType.inverted) {
        _stack.add(_nodes);
        _nodes = [];
        _nameStack.add(name);
        _inversionStack.add(type == _NodeType.inverted);
        _skipNode = true;
        
        if (processStandaloneTag()) {
          // Section start was on it's own line, indicies have already been updated
          continue;
        }
      }
      
      if (type == _NodeType.sectionEnd) {
        String startName = _nameStack.removeLast();
        if (name != startName) {
          throw new StateError("ERROR: $name doesn't match $startName");
        }
        bool inverted = _inversionStack.removeLast();
        _Node n = new _Node(name, inverted ? _NodeType.inverted : _NodeType.section, _nodes);
        _nodes = _stack.removeLast();
        _nodes.add(n);
        _skipNode = true;
        
        if (processStandaloneTag()) {
          // Section start was on it's own line, indicies have already been updated
          // print('$_nextStartIndex');
          continue;
        }
      }
      
      if (!_skipNode) {
        // print("adding $type node");
        _nodes.add(new _Node(name, type));
      }
      
      _nextStartIndex = _closeIndex + _delim.end.length;
    }
    
    if (_nextStartIndex < _tmplt.length) {
      // We've reached the end, and there's still stuff left
      _nodes.add(new _Node(_tmplt.substring(_nextStartIndex), _NodeType.text));
    }
    
    
    
    return _nodes;
  }
  
  bool ignoreOwnLined(_NodeType t) {
    switch (t) {
      case _NodeType.comment:
      case _NodeType.section:
      case _NodeType.inverted:
      case _NodeType.sectionEnd:
        return true;
      default: return false;
    }
  }
  
  // If a comment, section start, or section end is the only thing on a line, ignore that line.
  bool processStandaloneTag() {
    bool isAlone = isOnOwnLine();
    if (isAlone) {
      consumeLine();
    }
    return isAlone;
  }
  
  bool isOnOwnLine() {
    int lastCharIndex    = _openIndex > 0 ? _tmplt.lastIndexOf(_anyChar, _openIndex - 1) : -1;
    int lastNewlineIndex = _openIndex > 0 ? _tmplt.lastIndexOf(_newline, _openIndex - 1) : -1;
    
    int endOfClose = _closeIndex + _delim.end.length;
    int nextCharIndex    = endOfClose < _tmplt.length ? _tmplt.indexOf(_anyChar, _closeIndex + _delim.end.length) : _tmplt.length;
    int nextNewlineIndex = endOfClose < _tmplt.length ? _tmplt.indexOf(_newline, _closeIndex + _delim.end.length) : _tmplt.length;
    
    // If either of the 'nexts' returns -1, it's reached the end of the string
    if (nextCharIndex    == -1) nextCharIndex    = _tmplt.length;
    if (nextNewlineIndex == -1) nextNewlineIndex = _tmplt.length;
    
    bool isPrefixedByNewline  = lastCharIndex <= lastNewlineIndex;
    bool isPostfixedByNewline = nextNewlineIndex <= nextCharIndex;
    
    return isPrefixedByNewline && isPostfixedByNewline;
  }
  
  void consumeLine() {
    int lastNewlineIndex = _openIndex > 0 ? _tmplt.lastIndexOf(_newline, _openIndex - 1) : -1;
    int endOfClose = _closeIndex + _delim.end.length;
    int nextNewlineIndex = endOfClose < _tmplt.length ? _tmplt.indexOf(_newline, _closeIndex + _delim.end.length) : _tmplt.length;
    
    // If the 'next' returns -1, it's reached the end of the string
    if (nextNewlineIndex == -1) nextNewlineIndex = _tmplt.length;
    
    _nodes.add(new _Node(_tmplt.substring(_nextStartIndex, lastNewlineIndex + 1), _NodeType.text));
    _nextStartIndex = nextNewlineIndex + 1;
  }
  
  void processInterpolation() {
    if (_tmplt[_openIndex + _delim.start.length] == '{' && _tmplt[_closeIndex + _delim.end.length] == '}') {
      _closeIndex += 1;
      _skipNode = true;
      
      String name = _tmplt.substring(_openIndex + _delim.start.length + 1, _closeIndex - 1).trim();
      _nodes.add(new _Node(name, _NodeType.raw));
    }
  }
}