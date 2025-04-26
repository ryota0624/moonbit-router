///|
pub struct Route[Req, Res] {
  path : String
  methods : Array[String]
  handler : (Req) -> Res!Error + Async
}

///|
fn Route::new[Req, Res](
  path : String,
  methods : Array[String],
  handler : (Req) -> Res!Error + Async
) -> Route[Req, Res] {
  Route::{ path, methods, handler }
}

///|
fn Route::fromSafeHandler[Req, Res](
  path : String,
  methods : Array[String],
  handler : (Req) -> Res!Async
) -> Route[Req, Res] {
  Route::new(path, methods, async fn { req => handler!(req) })
}

///|
fn is_processable_request[Req : Request, Res](
  self : Route[Req, Res],
  request : Req
) -> Bool {
  is_method_matched(self, request) && is_path_matched(self, request)
}

///|
fn is_method_matched[Req : Request, Res](
  self : Route[Req, Res],
  request : Req
) -> Bool {
  // TODO: fix
  if self.methods.contains("*") {
    return true
  }
  self.methods.contains(request.method_())
}

///|
fn is_path_matched[Req : Request, Res](
  self : Route[Req, Res],
  request : Req
) -> Bool {
  // TODO: fix
  if self.path == "*" {
    return true
  }
  let path = request.url()
  if path == self.path {
    return true
  }
  if path.has_prefix(self.path) {
    return true
  }
  return false
}

///|
fn Route::process[Req : Request, Res : Response](
  self : Route[Req, Res],
  request : Req
) -> Res!Error + Async {
  (self.handler)!(request)
}

///|
test "Route::is_method_matched" {
  let request = DummyRequest::new(method_="GET", url="/test")
  let route = Route::new("/test", ["GET"], async fn(_) { return Ok(()) })
  assert_eq!(is_method_matched(route, request), true)
  assert_eq!(is_path_matched(route, request), true)
}
