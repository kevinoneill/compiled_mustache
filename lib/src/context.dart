part of handlebars4dart;

class _Context {
  _Context _parent = null;
  Object _obj = null;
  Map<String, Object> _map;
  
  factory _Context(Object o, [_Context par]) {
    if (o is Map<String, Object>) {
      return new _Context._internal(o, null, par);
    } else {
      return new _Context._internal(null, o, par);
    }
  }
  
  _Context._internal(Map<String, Object> this._map, Object this._obj, _Context this._parent);
  
  _Context subContext(String name) {
    Object o = get(name);
    if (o != null) {
      return new _Context(o, this);
    }
    return null;
  }
  
  Object get(String name) {
    Object out = null;
    if (name == '.') {
      out = _obj;
    } else {
      List<String> parts = name.split('.');
      String first = parts.removeAt(0);
      if (_map == null) {
        return _parent?.get(first);
      }
      out = _map[first] ?? _parent?.get(first);
      
      for (Object p in parts) {
        if (out is Map<String, Object>) {
          out = out[p];
        } else {
          break;
        }
      }
    }
    return out;
  }
}