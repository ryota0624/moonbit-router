///|
pub struct Route[BodyReader] {
  path : String
  methods : @immut/list.T[String]
  handler : async (Request, BodyReader) -> Response raise
}

///|
pub fn[BodyReader] Route::new(
  path : String,
  methods : Array[String],
  handler : async (Request, BodyReader) -> Response raise
) -> Route[BodyReader] {
  Route::{ path, methods: @immut/list.from_array(methods), handler }
}

///|
pub fn[BodyReader] Route::from_safe_handler(
  path : String,
  methods : Array[String],
  handler : (Request, BodyReader) -> Response raise
) -> Route[BodyReader] {
  Route::new(path, methods, async fn(req, reader) { handler(req, reader) })
}

///|
fn[BodyReader] is_processable_request(
  self : Route[BodyReader],
  request : Request
) -> Bool {
  self.is_method_matched(request) && self.is_path_matched(request)
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
async fn[BodyReader] Route::process(
  self : Route[BodyReader],
  request : Request,
  bodyReader : BodyReader
) -> Response raise {
  (self.handler)(request, bodyReader)
}
