///|
pub type PreMiddlewareFunc (Request, (Request) -> Response!Error + Async) -> Response!Error +
Async

///|
pub type PostMiddlewareFunc (Request, Response) -> Response!Error + Async

///|
pub enum Middleware {
  PreMiddleware(PreMiddlewareFunc)
  PostMiddleware(PostMiddlewareFunc)
}

///|
pub struct MiddlewareChain[BodyReader] {
  next : (Request, BodyReader) -> Response!Error + Async
}

///|
fn MiddlewareChain::new[BodyReader](
  requestHandler : (Request, BodyReader) -> Response!Error + Async
) -> MiddlewareChain[BodyReader] {
  MiddlewareChain::{ next: requestHandler }
}

///|
fn MiddlewareChain::add[BodyReader](
  self : MiddlewareChain[BodyReader],
  middleware : Middleware
) -> MiddlewareChain[BodyReader] {
  match middleware {
    PreMiddleware(middleware) =>
      MiddlewareChain::{
        next: fn(request, bodyReader) -> Response!Error + Async {
          let next = self.next
          (middleware._)!(request, fn(_) { next!(request, bodyReader) })
        },
      }
    PostMiddleware(middleware) =>
      MiddlewareChain::{
        next: fn(request, bodyReader) -> Response!Error + Async {
          let next = self.next
          let response = next!(request, bodyReader)
          (middleware._)!(request, response)
        },
      }
  }
}

///|
fn MiddlewareChain::handle[BodyReader](
  self : MiddlewareChain[BodyReader],
  request : Request,
  bodyReader : BodyReader
) -> Response!Error + Async {
  (self.next)!(request, bodyReader)
}

///|
pub fn request_logging_middleware() -> PreMiddlewareFunc {
  return fn(
    request : Request,
    next : (Request) -> Response!Error + Async
  ) -> Response!Error + Async {
    println("Request: " + request.to_string())
    next!(request)
  }
}

///|
pub fn response_logging_middleware() -> PostMiddlewareFunc {
  return fn(_ : Request, response : Response) -> Response!Async + Error {
    println("Response: " + response.to_string())
    Ok(response).unwrap_or_error!()
  }
}
