///|
struct Route[Req, Res] {
  middlewares : Array[MiddlewareFunc[Req, Res]]
  handler : (Req, (Res) -> Unit) -> Unit
}

///|
fn Route::new[Req, Res](
  handler : (Req, (Res) -> Unit) -> Unit
) -> Route[Req, Res] {
  return Route::{ middlewares: [], handler }
}

///|
fn Route::add_middleware[Req, Res](
  self : Route[Req, Res],
  middleware : MiddlewareFunc[Req, Res]
) -> Route[Req, Res] {
  return Route::{
    middlewares: self.middlewares + [middleware],
    handler: self.handler,
  }
}

///|
fn Route::handle[Req : Request, Res : Response](
  self : Route[Req, Res],
  request : Req,
  callback : (Res) -> Unit
) -> Unit {
  if self.middlewares.is_empty() {
    handle_request(request, callback)
  } else {
    let middleware_chain = self.middlewares.fold(
      init=MiddlewareChain::{
        request,
        next: fn(request) { (self.handler)(request, callback) },
        do_response: callback,
      },
      fn(chain, middleware) {
        MiddlewareChain::{
          request: chain.request,
          next: fn(_) { middleware.handle(chain) },
          do_response: chain.do_response,
        }
      },
    )
    middleware_chain.handle(request)
  }
}
