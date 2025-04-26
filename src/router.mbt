///| TODO: impl builder
pub struct Router[Req, Res] {
  middlewares : Array[MiddlewareFunc[Req, Res]]
  routes : Array[Route[Req, Res]]
  error_handler : ErrorHandler[Req, Res]
}

///|
pub type ErrorHandler[Req, Res] (Req, Error) -> Res!Error + Async
///|

///|
fn default_error_handler[Req : Request, Res : Response]() ->
     ErrorHandler[Req, Res] {
  ErrorHandler(fn(_, err) {
    println("occurred unexpected error:  ")
    println("occurred unexpected error:  " + err.to_string())
    Res::builder().status_code(500).text("internal server error")
  })
}

///|
pub fn Router::new[Req : Request, Res : Response](
  middlewares : Array[MiddlewareFunc[Req, Res]],
  routes : Array[Route[Req, Res]],
  error_handler : ErrorHandler[Req, Res]
) -> Router[Req, Res] {
  Router::{ middlewares, routes, error_handler }
}

///|
pub fn Router::process[Req : Request, Res : Response](
  self : Router[Req, Res],
  request : Req
) -> Res!Error + Async {
  let run = fn!() -> Res!Error + Async {
    let route = self.select_route(request)
    if route.is_empty() {
      fail!("Route not found")
    }
    guard route is Some(route) else { fail!("Route not found") }
    if self.middlewares.is_empty() {
      (route.handler)!(request)
    } else {
      let middleware_chain = self.middlewares.fold(
        init=MiddlewareChain::{
          request,
          next: fn(request) { (route.handler)!(request) },
        },
        fn(chain, middleware) {
          MiddlewareChain::{
            request: chain.request,
            next: fn(_) { middleware.handle!(chain) },
          }
        },
      )
      middleware_chain.handle!(request)
    }
  }
  try {
    run!()
  } catch {
    err => (self.error_handler._)!(request, err)
  }
}

///|
fn Router::select_route[Req : Request, Res](
  self : Router[Req, Res],
  request : Req
) -> Route[Req, Res]? {
  self.routes.filter(fn(route) { route.is_processable_request(request) }).get(0)
}
