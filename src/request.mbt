///|
pub trait Request: Show {
  bytes(Self, callback : (Result[FixedArray[Byte], Error]) -> Unit) -> Unit
  text(Self, callback : (Result[String, Error]) -> Unit) -> Unit
  json(Self, callback : (Result[Json, Error]) -> Unit) -> Unit
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
struct FakeRequest {
  url : String
  method_ : String
}

///|
impl Request for FakeRequest with bytes(
  self : FakeRequest,
  callback : (Result[FixedArray[Byte], Error]) -> Unit
) -> Unit {
  ...
}

///|
impl Request for FakeRequest with text(
  self : FakeRequest,
  callback : (Result[String, Error]) -> Unit
) -> Unit {
  ...
}

///|
impl Request for FakeRequest with json(
  self : FakeRequest,
  callback : (Result[Json, Error]) -> Unit
) -> Unit {
  ...
}

///|
impl Request for FakeRequest with headers(self : FakeRequest) -> &Headers {
  ...
}

///|
impl Request for FakeRequest with method_(self : FakeRequest) -> String {
  self.method_
}

///|
impl Request for FakeRequest with url(self : FakeRequest) -> String {
  self.url
}

///|
impl Request for FakeRequest with referrer(self : FakeRequest) -> String {
  ...
}

///|
impl Request for FakeRequest with mode(self : FakeRequest) -> String {
  ...
}

///|
impl Request for FakeRequest with destination(self : FakeRequest) -> String {
  ...
}

///|
impl Request for FakeRequest with credentials(self : FakeRequest) -> String {
  ...
}

///|
impl Request for FakeRequest with integrity(self : FakeRequest) -> String {
  ...
}

///|
impl Request for FakeRequest with redirect(self : FakeRequest) -> String {
  ...
}

///|
impl Request for FakeRequest with referrerPolicy(self : FakeRequest) -> String {
  ...
}

///|
impl Request for FakeRequest with keepalive(self : FakeRequest) -> Bool {
  ...
}

///|
impl Show for FakeRequest with output(self : FakeRequest, logger : &Logger) -> Unit {
  logger.write_string("FakeRequest")
  logger.write_string("url: " + self.url())
  logger.write_string("method: " + self.method_())
}
