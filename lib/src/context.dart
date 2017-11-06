part of handlebars4dart;

class _Context {
  _Context _parent = null;
  Object _obj = null;
  Map<String, Object> _map;
  
  _Context(Map<String, Object> map) {
    _map = map;
  }
  
  Object get(String name) {
    Object out = null;
    if (name == '.') {
      out = _obj;
    } else {
      List<String> parts = name.split('.');
      String first = parts.removeAt(0);
      out = _map[first] ?? _parent?.get(first);
      
      for (Object p in parts) {
        if (out is Map<String, Object>) {
          out = out[p];
        } else {
          break;
        }
      }
    }
    return (out ?? '').toString();
  }
}