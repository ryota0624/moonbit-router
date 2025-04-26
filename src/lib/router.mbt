///| TODO: impl builder
pub struct Router[BodyReader] {
  preMiddleware : Array[PreMiddlewareFunc]
  postMiddleware : Array[PostMiddlewareFunc]
  routes : Array[Route[BodyReader]]
  error_handler : ErrorHandler
}

///|
pub type ErrorHandler (Request, Error) -> Response!Error + Async
///|

///|
pub fn default_error_handler() -> ErrorHandler {
  ErrorHandler(fn(_, err) {
    println("occurred unexpected error:  " + err.to_string())
    Response::{
      status_code: 500,
      response_headers: @immut/list.from_array([]),
      body: String("internal server error"),
    }
  })
}

///|
pub fn Router::new[Reader : BodyReader](
  preMiddleware : Array[PreMiddlewareFunc],
  postMiddleware : Array[PostMiddlewareFunc],
  routes : Array[Route[Reader]],
  error_handler : ErrorHandler
) -> Router[Reader] {
  Router::{ preMiddleware, postMiddleware, routes, error_handler }
}


///|
pub fn Router::process[Reader : BodyReader](
  self : Router[Reader],
  request : Request,
  bodyReader : Reader,
) -> Response!Error + Async {
  let run = fn!() -> Response!Error + Async {
    let route = self.select_route(request)
    if route.is_empty() {
      fail!("Route not found")
    }
    guard route is Some(route) else { fail!("Route not found") }
    if self.preMiddleware.is_empty() {
      (route.handler)!(request, bodyReader)
    } else {
      let pre_middleware_chain = self.preMiddleware.fold(
        init=MiddlewareChain::{ next: route.handler },
        fn(chain, middleware) { chain.add(PreMiddleware(middleware)) },
      )
      let postMiddleware_chain = self.postMiddleware.fold(
        init=pre_middleware_chain,
        fn(chain, middleware) { chain.add(PostMiddleware(middleware)) },
      )
      postMiddleware_chain.handle!(request, bodyReader)
    }
  }
  try {
    run!()
  } catch {
    err => (self.error_handler._)!(request, err)
  }
}

///|
fn Router::select_route[Reader : BodyReader](
  self : Router[Reader],
  request : Request
) -> Route[Reader]? {
  self.routes.filter(fn(route) { route.is_processable_request(request) }).get(0)
}
