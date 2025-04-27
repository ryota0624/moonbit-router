///| TODO: impl builder
pub struct Router[BodyReader] {
  pre_middleware : Array[PreMiddlewareFunc]
  post_middleware : Array[PostMiddlewareFunc]
  routes : Array[Route[BodyReader]]
  error_handler : ErrorHandler
}

///|
pub type ErrorHandler (Request, Error) -> Response!Error + Async
///|

///|
pub fn default_error_handler() -> ErrorHandler {
  fn(_, err) {
    println("occurred unexpected error:  " + err.to_string())
    Response::{
      status_code: 500,
      response_headers: @immut/list.from_array([]),
      body: String("internal server error"),
    }
  }
}

///|
pub fn Router::new[Reader : BodyReader](
  pre_middleware~ : Array[PreMiddlewareFunc],
  post_middleware~ : Array[PostMiddlewareFunc],
  routes : Array[Route[Reader]],
  error_handler : ErrorHandler
) -> Router[Reader] {
  Router::{ pre_middleware, post_middleware, routes, error_handler }
}

///|
pub fn Router::process[Reader : BodyReader](
  self : Router[Reader],
  request : Request,
  bodyReader : Reader
) -> Response!Error + Async {
  try {
    self._process!(request, bodyReader)
  } catch {
    err => (self.error_handler._)!(request, err)
  }
}

///|
fn Router::_process[Reader : BodyReader](
  self : Router[Reader],
  request : Request,
  bodyReader : Reader
) -> Response!Error + Async {
  let route = self.select_route(request)
  if route.is_empty() {
    fail!("Route not found")
  }
  guard route is Some(route) else { fail!("Route not found") }
  let pre_middleware_chain = self.pre_middleware
    .rev()
    .fold(init=MiddlewareChain::{ next: route.handler }, fn(chain, middleware) {
      chain.add(PreMiddleware(middleware))
    })
  let post_middleware_chain = self.post_middleware.fold(
    init=pre_middleware_chain,
    fn(chain, middleware) { chain.add(PostMiddleware(middleware)) },
  )
  post_middleware_chain.handle!(request, bodyReader)
}

///|
test "Router::process内ではpre_middleware -> handler -> post_middlewareの順で実行される" {
  run_async(async fn() {
    let called : Array[String] = []
    let router : Router[FakeBodyReader] = Router::new(
      pre_middleware=[
        fn(request, next) {
          called.push("pre_middleware1")
          next!(request)
        },
        fn(request, next) {
          called.push("pre_middleware2")
          next!(request)
        },
      ],
      post_middleware=[
        fn(_, response) {
          called.push("post_middleware1")
          response
        },
        fn(_, response) {
          called.push("post_middleware2")
          response
        },
      ],
      [
        Route::new("*", ["*"], fn(_, _) {
          called.push("handler")
          Response::from_string(
            "Hello, world!",
            status_code=200,
            response_headers=@immut/list.from_array([]),
          )
        }),
      ],
      default_error_handler(),
    )
    try {
      let _ = router.process!(
        Request::from(
          url="http://example.com/test".to_string(),
          method_="GET".to_string(),
        ),
        FakeBodyReader::default(),
      )
      assert_eq!(called, ["pre_middleware1", "pre_middleware2" , "handler", "post_middleware1", "post_middleware2"])
    } catch {
      err => println("Error: " + err.to_string())
    }
  })
}

///|
fn Router::select_route[Reader : BodyReader](
  self : Router[Reader],
  request : Request
) -> Route[Reader]? {
  self.routes.filter(fn(route) { route.is_processable_request(request) }).get(0)
}
