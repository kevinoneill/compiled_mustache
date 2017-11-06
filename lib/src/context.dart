part of handlebars4dart;

class _Context {
  _Context _parent = null;
  Map<String, Object> _map;
  
  _Context(Map<String, Object> map) {
    _map = map;
  }
  
  Object get(String name) {
    Object o = _map[name] ?? _parent?.get(name);
    return (o ?? '').toString();
  }
}