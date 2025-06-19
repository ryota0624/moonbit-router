///|
pub struct Route[BodyReader] {
  path : String
  methods : @immut/list.T[String]
  handler : (Request, BodyReader) -> Response!Error + Async
}

///|
pub fn Route::new[BodyReader](
  path : String,
  methods : Array[String],
  handler : (Request, BodyReader) -> Response!Error + Async
) -> Route[BodyReader] {
  Route::{ path, methods: @immut/list.from_array(methods), handler }
}

///|
pub fn[BodyReader] Route::from_safe_handler(
  path : String,
  methods : Array[String],
  handler : (Request, BodyReader) -> Response raise Async
) -> Route[BodyReader] {
  Route::new(path, methods, async fn(req, reader) { handler(req, reader) })
}

///|
fn[BodyReader] is_processable_request(
  self : Route[BodyReader],
  request : Request
) -> Bool {
  is_method_matched(self, request) && is_path_matched(self, request)
}

///|
fn[BodyReader] is_method_matched(
  self : Route[BodyReader],
  request : Request
) -> Bool {
  // TODO: fix
  if self.methods.contains("*") {
    return true
  }
  self.methods.contains(request.method_)
}

///|
fn[BodyReader] is_path_matched(
  self : Route[BodyReader],
  request : Request
) -> Bool {
  // TODO: fix
  if self.path == "*" {
    return true
  }
  let path = request.url
  if path == self.path {
    return true
  }
  if path.has_prefix(self.path) {
    return true
  }
  return false
}

///|
fn Route::process[BodyReader](
  self : Route[BodyReader],
  request : Request,
  bodyReader : BodyReader
) -> Response!Error + Async {
  (self.handler)!(request, bodyReader)
}
