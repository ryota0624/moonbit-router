///| TODO: impl builder
pub struct Router[Req, Res] {
  preMiddleware : Array[PreMiddlewareFunc[Req, Res]]
  postMiddleware : Array[PostMiddlewareFunc[Req, Res]]
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
    println("occurred unexpected error:  " + err.to_string())
    Res::builder().status_code(500).text("internal server error")
  })
}

///|
pub fn Router::new[Req : Request, Res : Response](
  preMiddleware : Array[PreMiddlewareFunc[Req, Res]],
  postMiddleware : Array[PostMiddlewareFunc[Req, Res]],
  routes : Array[Route[Req, Res]],
  error_handler : ErrorHandler[Req, Res]
) -> Router[Req, Res] {
  Router::{ preMiddleware, postMiddleware, routes, error_handler }
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
    if self.preMiddleware.is_empty() {
      (route.handler)!(request)
    } else {
      let  pre_middleware_chain = self.preMiddleware.fold(
        init=MiddlewareChain::{ next: route.handler },
        fn(chain, middleware) { chain.add(PreMiddleware(middleware)) },
      )
      let postMiddleware_chain = self.postMiddleware.fold(init=pre_middleware_chain, fn(
        chain,
        middleware
      ) {
        chain.add(PostMiddleware(middleware))
      })
      postMiddleware_chain.handle!(request)
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
