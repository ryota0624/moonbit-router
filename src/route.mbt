///|
pub struct Route[Req, Res] {
  path : String
  methods : Array[String]
  handler : (Req, (Res) -> Unit) -> Unit!
}

///|
fn Route::new[Req, Res](
  path : String,
  methods : Array[String],
  handler : (Req, (Res) -> Unit) -> Unit!
) -> Route[Req, Res] {
  Route::{ path, methods, handler }
}

fn Route::newFromResult[Req, Res](
  path : String,
  methods : Array[String],
  handler : (Req, (Res) -> Unit) -> Result[Unit, Error]
) -> Route[Req, Res] {
  Route::new(
    path,
    methods,
    fn(request, callback) {
      let result = handler(request, callback)
      match result {
        Ok(_) => return
        Err(err) => fail!(err.to_string())
      }
    }
  )
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
  request : Req,
  callback : (Res) -> Unit
) -> Unit! {
  (self.handler)!(request, callback)
}

///|
test "Route::is_method_matched" {

}
