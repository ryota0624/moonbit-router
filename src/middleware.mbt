///|
pub type PreMiddlewareFunc[Req, Res] (Req, (Req) -> Res!Error + Async) -> Res!Error +
Async

///|
pub type PostMiddlewareFunc[Req, Res] (Req, Res) -> Res!Error + Async

///|
enum Middleware[Req, Res] {
  PreMiddleware(PreMiddlewareFunc[Req, Res])
  PostMiddleware(PostMiddlewareFunc[Req, Res])
}

///|
fn PreMiddlewareFunc::handle[Req, Res](
  self : PreMiddlewareFunc[Req, Res],
  input : Req,
  next : (Req) -> Res!Error + Async
) -> Res!Error + Async {
  (self._)!(input, next)
}

///|
fn PostMiddlewareFunc::handle[Req, Res](
  self : PostMiddlewareFunc[Req, Res],
  input : Req,
  output : Res
) -> Res!Error + Async {
  (self._)!(input, output)
}

///|
fn PreMiddlewareFunc::new[Req, Res](
  func : (Req, (Req) -> Res!Error + Async) -> Res!Error + Async
) -> PreMiddlewareFunc[Req, Res] {
  return func
}

///|
fn PostMiddlewareFunc::new[Req, Res](
  func : (Req, Res) -> Res!Async
) -> PostMiddlewareFunc[Req, Res] {
  return async fn { req, res => func!(req, res) }
}

///|
pub struct MiddlewareChain[Req, Res] {
  next : (Req) -> Res!Error + Async
}

///|
fn MiddlewareChain::add[Req, Res](
  self : MiddlewareChain[Req, Res],
  middleware : Middleware[Req, Res]
) -> MiddlewareChain[Req, Res] {
  match middleware {
    PreMiddleware(middleware) =>
      MiddlewareChain::{ next: fn(req) { middleware.handle!(req, self.next) } }
    PostMiddleware(middleware) =>
      MiddlewareChain::{
        next: fn(req) { middleware.handle!(req, self.handle!(req)) },
      }
  }
}

///|
fn MiddlewareChain::handle[Req, Res](
  self : MiddlewareChain[Req, Res],
  request : Req
) -> Res!Error + Async {
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
) -> PreMiddlewareFunc[Req, Res] {
  async fn handle!(
    request : Req,
    next : (Req) -> Res!Error + Async
  ) -> Res!Error + Async {
    self.handle!(request, next)
  }

  return PreMiddlewareFunc::new(handle)
}

///|
fn BasicAuthMiddleware::handle[Req : Request, Res : Response](
  self : BasicAuthMiddleware,
  request : Req,
  next : (Req) -> Res!Error + Async
) -> Res!Error + Async {
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
      Res::builder()
      .status_code(401)
      .response_headers_add(Header::{ name: "WWW-Authenticate", value: "Basic" })
      .text("Unauthorized")
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
     PreMiddlewareFunc[Req, Res] {
  return PreMiddlewareFunc::new(fn(
    request : Req,
    next : (Req) -> Res!Error + Async
  ) -> Res!Error + Async {
    println("Request: " + request.to_string())
    next!(request)
  })
}

///|
fn response_logging_middleware[Req : Request, Res : Response]() ->
     PostMiddlewareFunc[Req, Res] {
  return PostMiddlewareFunc::new(fn(_ : Req, response : Res) -> Res!Async {
    println("Response")
    response
  })
}

///|
fn request_url_logging_middleware[Req : Request, Res : Response]() ->
     PreMiddlewareFunc[Req, Res] {
  return PreMiddlewareFunc::new(fn(req : Req, next) {
    println("URL Logging: " + req.url())
    next!(req)
  })
}
