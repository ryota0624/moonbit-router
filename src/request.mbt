///|
pub trait Request: Show {
  bytes(Self) -> FixedArray[Byte]!Error + Async
  text(Self) -> String!Error + Async
  json(Self) -> Json!Error + Async
  headers(Self) -> &Headers
  method_(Self) -> String
  url(Self) -> String
  referrer(Self) -> String
  mode(Self) -> String
  destination(Self) -> String
  credentials(Self) -> String
  integrity(Self) -> String
  redirect(Self) -> String
  referrerPolicy(Self) -> String
  keepalive(Self) -> Bool
}

///|
pub struct DummyRequest {
  url : String
  method_ : String
}

///|
fn DummyRequest::new(url~ : String, method_~ : String) -> DummyRequest {
  DummyRequest::{ url, method_ }
}

///|
impl Request for DummyRequest with bytes(_ : DummyRequest) -> FixedArray[Byte]!Error +
Async {
  ...
}

///|
impl Request for DummyRequest with text(_ : DummyRequest) -> String!Error +
Async {
  ...
}

///|
impl Request for DummyRequest with json(_ : DummyRequest) -> Json!Error + Async {
  ...
}

///|
impl Request for DummyRequest with headers(_ : DummyRequest) -> &Headers {
  ...
}

///|
impl Request for DummyRequest with method_(self : DummyRequest) -> String {
  self.method_
}

///|
impl Request for DummyRequest with url(self : DummyRequest) -> String {
  self.url
}

///|
impl Request for DummyRequest with referrer(_ : DummyRequest) -> String {
  ...
}

///|
impl Request for DummyRequest with mode(_ : DummyRequest) -> String {
  ...
}

///|
impl Request for DummyRequest with destination(_ : DummyRequest) -> String {
  ...
}

///|
impl Request for DummyRequest with credentials(_ : DummyRequest) -> String {
  ...
}

///|
impl Request for DummyRequest with integrity(_ : DummyRequest) -> String {
  ...
}

///|
impl Request for DummyRequest with redirect(_ : DummyRequest) -> String {
  ...
}

///|
impl Request for DummyRequest with referrerPolicy(_ : DummyRequest) -> String {
  ...
}

///|
impl Request for DummyRequest with keepalive(_ : DummyRequest) -> Bool {
  ...
}

///|
impl Show for DummyRequest with output(self : DummyRequest, logger : &Logger) -> Unit {
  logger.write_string("FakeRequest")
  logger.write_string("url: " + self.url())
  logger.write_string("method: " + self.method_())
}
