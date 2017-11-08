part of handlebars4dart;

class CompiledTemplate {
  List<_Node> _nodes;
  
  CompiledTemplate(List<_Node> this._nodes) {
    _cleanup();
    _consolidateTextNodes();
  }
  
  
  String render(Map<String, Object> context) {
    return _render(new _Context(context));
  }
  
  String _render(_Context cntxt) {
    String s = '';
    for (_Node n in _nodes) {
      s += n.render(cntxt);
    }
    return s;
  }
  
  
  CompiledTemplate compileWithPartials(Map<String, Object> partials) {
    if (partials == null) {
      throw new ArgumentError.notNull('partials');
    }
    
    // Make sure all partials are of type `CompiledPartial`
    Map<String, CompiledTemplate> compiledPartials = {};
    for (String n in partials.keys) {
      Object o = partials[n];
      if (o is CompiledTemplate) {
        compiledPartials[n] = o;
      } else if (o is String) {
        compiledPartials[n] = compile(o);
      } // If the item isn't a template or a string, ignore it.
    }
    
    // Compile all partials -- allows for recursivity
    Map<String, CompiledTemplate> fullyCompiledPartials = {};
    for (String n in compiledPartials.keys) {
      CompiledTemplate p = compiledPartials[n];
      fullyCompiledPartials[n] = p._compileWithPartials(compiledPartials);
    }
    
    return _compileWithPartials(fullyCompiledPartials);
  }
  
  CompiledTemplate _compileWithPartials(Map<String, CompiledTemplate> partials) {
    _splitOnLines();
    List<_Node> nodes = [];
    for (_Node n in _nodes) {
      nodes.addAll(n.renderPartials(partials));
    }
    return new CompiledTemplate(nodes);
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
    if (n._data == null || n._data.isEmpty) return null; //Invalid / empty node, ignore it
    
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
  
  
  void _splitOnLines() {
    List<_Node> nodes = [];
    for (_Node n in _nodes) {
      nodes.addAll(_lineSplitNode(n));
    }
    _nodes = nodes;
  }
  
  List<_Node> _lineSplitNode(_Node n) {
    if (n._data == null || n._data.isEmpty) return const []; //Invalid / empty node, ignore it
    
    switch (n._type) {
      case _NodeType.text:
        int nlIndex = n._data.indexOf('\n');
        if (nlIndex == -1) return [n]; //No newlines, nothing to do here.
        if (nlIndex == n._data.length-1) return [n]; //Newline is at end of line, no more work needed.
        //Newline is somwhere in middle, split into multiple lines.
        
        List<String> split = n._data.split('\n');
        List<String> lines = [split.removeAt(0)];
        for (int i = 0; i < split.length; i++) {
          lines[i] += '\n';
          lines.add(split[i]);
        }
        List<_Nodes> lineNodes = [];
        for (String l in lines) {
          if (l.isNotEmpty) {
            lineNodes.add(new _Node(l, _NodeType.text));
          }
        }
        return lineNodes;
      case _NodeType.section:
      case _NodeType.inverted:
        List<_Node> nodes = [];
        for (_Node nn in n._contents) {
          nodes.addAll(_lineSplitNode(nn));
        }
        return [new _Node(n._data, n._type, nodes)];
      default:
        return [n];
    }
  }
  
  
  void _consolidateTextNodes() {
    _nodes = _consolidateNodes(_nodes);
  }
  
  List<_Node> _consolidateNodes(List<_Node> nodes) {
    _Node lastTextNodeOnSameLine = null;
    List<_Node> ns = [];
    for (_Node n in nodes) {
      if (n._type == _NodeType.text) {
        if (lastTextNodeOnSameLine != null) {
          lastTextNodeOnSameLine = new _Node(lastTextNodeOnSameLine._data + n._data, _NodeType.text);
        } else {
          lastTextNodeOnSameLine = n;
        }
        if (lastTextNodeOnSameLine._data[lastTextNodeOnSameLine._data.length-1] == '\n') {
          ns.add(lastTextNodeOnSameLine);
          lastTextNodeOnSameLine = null;
        }
      } else {
        if (lastTextNodeOnSameLine != null) {
          ns.add(lastTextNodeOnSameLine);
          lastTextNodeOnSameLine = null;
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