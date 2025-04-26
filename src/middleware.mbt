///|
pub type MiddlewareFunc[Req, Res] (MiddlewareChain[Req, Res]) -> Unit!

///|
fn MiddlewareFunc::handle[Req, Res](
  self : MiddlewareFunc[Req, Res],
  input : MiddlewareChain[Req, Res]
) -> Unit! {
  (self._)!(input)
}

///|
fn MiddlewareFunc::new[Req, Res](
  func : (Req, (Req) -> Unit!, (Res) -> Unit) -> Unit!
) -> MiddlewareFunc[Req, Res] {
  fn middleware(input : MiddlewareChain[Req, Res]) -> Unit! {
    func!(input.request, input.next, input.do_response)
  }

  return middleware
}

///|
pub struct MiddlewareChain[Req, Res] {
  next : (Req) -> Unit!
  do_response : (Res) -> Unit
  request : Req
}

///|
fn MiddlewareChain::handle[Req, Res](
  self : MiddlewareChain[Req, Res],
  request : Req
) -> Unit! {
  (self.next)!(request)
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
fn BasicAuthMiddleware::new(
  username : String,
  password : String
) -> BasicAuthMiddleware {
  return BasicAuthMiddleware::{ users: [BasicAuthUser::{ username, password }] }
}

///|
fn BasicAuthMiddleware::install[Req : Request, Res : Response](
  self : BasicAuthMiddleware
) -> MiddlewareFunc[Req, Res] {
  fn handle!(
    request : Req,
    next : (Req) -> Unit!,
    do_response : (Res) -> Unit
  ) {
    self.handle!(request, next, do_response)
  }

  return MiddlewareFunc::new(handle)
}

///|
fn BasicAuthMiddleware::handle[Req : Request, Res : Response](
  self : BasicAuthMiddleware,
  request : Req,
  next : (Req) -> Unit!,
  do_response : (Res) -> Unit
) -> Unit! {
  let auth_user = request
    .headers()
    .get("authorization")
    .bind(fn(header) {
      header.split(" ").to_array().get(1).map(fn { value => value.to_string() })
    })
    .bind(BasicAuthUser::fromAuthorizationHeader)
  let registered = auth_user.filter(fn(user) { self.is_registered(user) })
  match registered {
    Some(_) => next!(request)
    None =>
      do_response(
        Res::builder()
        .status_code(401)
        .response_headers_add(Header::{
          name: "WWW-Authenticate",
          value: "Basic",
        })
        .text("Unauthorized"),
      )
  }
}

///|
struct BasicAuthUser {
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

///|
fn request_logging_middleware[Req : Request, Res : Response]() ->
     MiddlewareFunc[Req, Res] {
  let fns = fn(request : Req, next : (Req) -> Unit!, _) -> Unit! {
    println("Request: " + request.to_string())
    next!(request)
  }
  return MiddlewareFunc::new(fns)
}

///|
fn request_url_logging_middleware[Req : Request, Res : Response]() ->
     MiddlewareFunc[Req, Res] {
  let fns = fn!(request : Req, next : (Req) -> Unit!, _) {
    println("URL Logging: " + request.url())
    next!(request)
  }
  return MiddlewareFunc::new(fns)
}
