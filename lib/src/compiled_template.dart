part of compiled_mustache;

/// A compiled mustache template.
class CompiledTemplate {
  List<_Node> _nodes;
  
  CompiledTemplate._internal(List<_Node> this._nodes) {
    _cleanup();
    _consolidateTextNodes();
  }
  
  /// Render this template using the given context and partials.
  ///
  /// This is different from [renderWithPartialProvider] because it uses a static [Map]
  /// from which to pull the partials. This is useful if you are defining all the partials
  /// in your code.
  String render(Map<String, Object> context, Map<String, Object> partials) {
    if (partials == null) {
      return _render(new _Context(context), (n) => null);
    } else {
      // Make sure all partials are of type [CompiledPartial].
      Map<String, CompiledTemplate> compiledPartials = {};
      for (String n in partials.keys) {
        Object o = partials[n];
        if (o is CompiledTemplate) {
          compiledPartials[n] = o;
        } else if (o is String) {
          compiledPartials[n] = compile(o);
        } // If the item isn't a template or a string, ignore it.
      }
      
      return _render(new _Context(context), (n) => compiledPartials[n]);
    }
  }
  
  /// Render this template using the given context and partialsProvider.
  ///
  /// This is different from [render] because instead of a static [Map] of partials
  /// it calls the provided getter each time it needs a partial. This can be used to cache partials if
  /// they are being loaded off disk.
  String renderWithPartialProvider(Map<String, Object> context, CompiledTemplate partialProvider(String name)) {
    return _render(new _Context(context), partialProvider);
  }
  
  String _render(_Context cntxt, CompiledTemplate partialProvider(String name), [String indent = '']) {
    String s = '';
    for (_Node n in _nodes) {
      s += n.render(cntxt, partialProvider, indent);
    }
    
    // Remove indentation after last line (if it ends in a newline, don't indent the next line).
    if (s.lastIndexOf('\n$indent') == s.length - '\n$indent'.length) {
      s = s.substring(0, s.length - indent.length);
    }
    
    // Indent first line.
    return indent + s;
  }
  
  
  void _cleanup() {
    List<_Node> nodes = [];
    for (_Node n in _nodes) {
      _Node newNode = _cleanupNode(n);
      if (newNode != null) {
        nodes.add(newNode);
      }
    }
    _nodes = nodes;
  }
  
  _Node _cleanupNode(_Node n) {
    if (n._data == null || n._data.isEmpty) return null; //Invalid / empty node, ignore it.
    
    switch (n._type) {
      case _NodeType.section:
      case _NodeType.inverted:
        List<_Node> nodes = [];
        for (_Node nn in n._contents) {
          _Node newNode = _cleanupNode(nn);
          if (newNode != null) {
            nodes.add(newNode);
          }
        }
        return new _Node(n._data, n._type, nodes);
      default:
        return n;
    }
  }
  
  void _consolidateTextNodes() {
    _nodes = _consolidateNodes(_nodes);
  }
  
  List<_Node> _consolidateNodes(List<_Node> nodes) {
    _Node lastTextNode = null;
    List<_Node> ns = [];
    for (_Node n in nodes) {
      if (n._type == _NodeType.text) {
        if (lastTextNode != null) {
          lastTextNode = new _Node(lastTextNode._data + n._data, _NodeType.text);
        } else {
          lastTextNode = n;
        }
      } else {
        if (lastTextNode != null) {
          ns.add(lastTextNode);
          lastTextNode = null;
        }
        switch (n._type) {
          case _NodeType.section:
          case _NodeType.inverted:
            ns.add(new _Node(n._data, n._type, _consolidateNodes(n._contents)));
            break;
          default:
            ns.add(n);
        }
      }
    }
    return nodes;
  }
}