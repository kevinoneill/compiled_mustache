part of compiled_mustache;

class _Context {
  final _Context _parent;
  final dynamic _obj;
  final Map<String, dynamic> _map;

  factory _Context(Object o, [_Context par]) {
    if (o is Map<String, Object>) {
      return new _Context._internal(o, null, par);
    } else {
      return new _Context._internal(null, o, par);
    }
  }

  _Context._internal(this._map, this._obj, this._parent);

  _Context subContext(String name) {
    Object o = get(name);
    if (o != null) {
      return new _Context(o, this);
    }
    return null;
  }

  Object get(String name) {
    dynamic out;
    if (name == '.') {
      out = _obj;
    } else {
      final List<String> parts = name.split('.');
      final String first = parts.removeAt(0);
      if (_map == null) {
        return _parent?.get(first);
      }
      out = _map[first] ?? _parent?.get(first);

      for (Object p in parts) {
        if (out is Map<String, dynamic>) {
          out = out[p];
        } else {
          break;
        }
      }
    }
    return out;
  }
}
