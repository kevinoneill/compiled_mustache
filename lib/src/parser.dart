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
      _NodeType type = _NodeType.interpolation;
      switch (name[0]) {
        case '!':
          type = _NodeType.comment;
          break;
        case '=':
          type = _NodeType.delimiter;
          break;
        case '>':
          type = _NodeType.partial;
          break;
        case '#':
          type = _NodeType.section;
          break;
        case '^':
          type = _NodeType.inverted;
          break;
      }
      if (type == _NodeType.comment && processComment()) {
        // Comment was on it's own line, indicies have already been updated
        continue;
      }
      if (_openIndex > 0) {
        // Capture the stuff before the tag
        _nodes.add(new _Node(_tmplt.substring(_nextStartIndex, _openIndex), _NodeType.text));
      }
      
      if (!_skipNode) {
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
  
  bool processComment() {
    int lastCharIndex    = _tmplt.lastIndexOf(_anyChar, _openIndex - 1);
    int lastNewlineIndex = _tmplt.lastIndexOf(_newline, _openIndex - 1);
    
    int nextCharIndex    = _tmplt.indexOf(_anyChar, _closeIndex + _delim.end.length);
    int nextNewlineIndex = _tmplt.indexOf(_newline, _closeIndex + _delim.end.length);
    
    // If either of the 'nexts' returns -1, it's reached the end of the string
    if (nextCharIndex    == -1) nextCharIndex    = _tmplt.length;
    if (nextNewlineIndex == -1) nextNewlineIndex = _tmplt.length;
    
    bool isPrefixedByNewline  = lastCharIndex <= lastNewlineIndex;
    bool isPostfixedByNewline = nextNewlineIndex <= nextCharIndex;
    
    if (isPrefixedByNewline && isPostfixedByNewline) {
      _nodes.add(new _Node(_tmplt.substring(_nextStartIndex, lastNewlineIndex + 1), _NodeType.text));
      _nextStartIndex = nextNewlineIndex + 1;
      return true; //Ignore comments
    }
    
    _skipNode = true;
    return false;
  }
}