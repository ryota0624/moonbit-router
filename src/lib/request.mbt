///|
pub struct Request {
  headers : Headers
  url : String
  method_ : String
  referrer : String
  mode : String
  destination : String
  credentials : String
  integrity : String
  redirect : String
  referrerPolicy : String
  keepalive : Bool
} derive(Show)

///|
pub fn Request::new(
  headers~ : @immut/list.T[Header],
  url~ : String,
  method_~ : String,
  referrer~ : String,
  mode~ : String,
  destination~ : String,
  credentials~ : String,
  integrity~ : String,
  redirect~ : String,
  referrerPolicy~ : String,
  keepalive~ : Bool
) -> Request {
  Request::{
    headers: Headers::new(headers),
    url,
    method_,
    referrer,
    mode,
    destination,
    credentials,
    integrity,
    redirect,
    referrerPolicy,
    keepalive,
  }
}

///|
fn Request::from(url~ : String, method_~ : String) -> Request {
  Request::{
    headers: Headers::new(@immut/list.from_array([])),
    url,
    method_,
    referrer: "".to_string(),
    mode: "cors".to_string(),
    destination: "document".to_string(),
    credentials: "same-origin".to_string(),
    integrity: "".to_string(),
    redirect: "follow".to_string(),
    referrerPolicy: "".to_string(),
    keepalive: false,
  }
}

///|
pub(open) trait BodyReader {
  async bytes(Self) -> FixedArray[Byte] raise
  async text(Self) -> String raise
  async json(Self) -> Json raise
}

///|
struct FakeBodyReader {
  bytes : FixedArray[Byte]
  text : String
  json : Json
}

///|
impl Default for FakeBodyReader with default() {
  FakeBodyReader::{
    bytes: FixedArray::from_array([]),
    text: "".to_string(),
    json: {},
  }
}

///|
fn FakeBodyReader::copy(
  self : FakeBodyReader,
  bytes? : FixedArray[Byte],
  text? : String,
  json? : Json
) -> FakeBodyReader {
  FakeBodyReader::{
    bytes: bytes.or_else(fn() { self.bytes }),
    text: text.or_else(fn() { self.text }),
    json: json.or_else(fn() { self.json }),
  }
}

///|
impl BodyReader for FakeBodyReader with bytes(self : FakeBodyReader) -> FixedArray[
  Byte,
] raise {
  self.bytes
}

///|
impl BodyReader for FakeBodyReader with text(self : FakeBodyReader) -> String raise {
  self.text
}

///|
impl BodyReader for FakeBodyReader with json(self : FakeBodyReader) -> Json raise {
  self.json
}
