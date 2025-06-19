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

pub fn response_logging_middleware2() -> PostMiddlewareFunc {
  return fn(_ : Request, response : Response) -> Response!Async + Error {
    println("Response2: " + response.to_string())
    Ok(response).unwrap_or_error!()
  }
}

///|
struct BasicAuthMiddleware {
  users : Array[BasicAuthUser]
}

///|
fn BasicAuthMiddleware::is_registered(
  self : BasicAuthMiddleware,
  input_user : BasicAuthUser
) -> Bool {
  self.users.contains(input_user)
}

///|
pub fn BasicAuthMiddleware::new(
  username : String,
  password : String
) -> BasicAuthMiddleware {
  return BasicAuthMiddleware::{ users: [BasicAuthUser::{ username, password }] }
}

///|
pub fn BasicAuthMiddleware::install(
  self : BasicAuthMiddleware
) -> PreMiddlewareFunc {
  return async fn!(
    request : Request,
    next : (Request) -> Response!Error + Async
  ) -> Response!Error + Async {
    self.handle!(request, next)
  }
}

///|
fn BasicAuthMiddleware::handle(
  self : BasicAuthMiddleware,
  request : Request,
  next : (Request) -> Response!Error + Async
) -> Response!Error + Async {
  let auth_user = request.headers
    .get("authorization")
    .bind(fn(header) {
      header.split(" ").to_array().get(1).map(fn { value => value.to_string() })
    })
    .bind(BasicAuthUser::fromAuthorizationHeader)
  let registered = auth_user.filter(fn(user) { self.is_registered(user) })
  match registered {
    Some(_) => next!(request)
    None =>
      Response::from_string(
        status_code=401,
        response_headers=@immut/list.from_array([
          Header::{ name: "WWW-Authenticate", value: "Basic" },
        ]),
        "Unauthorized",
      )
  }
}

///|
pub struct BasicAuthUser {
  username : String
  password : String
} derive(Show)

///|
impl Eq for BasicAuthUser with op_equal(
  self : BasicAuthUser,
  other : BasicAuthUser
) -> Bool {
  return self.username == other.username && self.password == other.password
}

///|
extern "js" fn base64_decode(input : String) -> String =
  #| (input) => Buffer.from(input, 'base64').toString()

///|
fn BasicAuthUser::fromAuthorizationHeader(header : String) -> BasicAuthUser? {
  let authorization = base64_decode(header)
  let credentials = authorization.split(":").to_array()
  guard credentials is [username, password] else { return None }
  return Some(BasicAuthUser::{
    username: username.to_string(),
    password: password.to_string(),
  })
}
