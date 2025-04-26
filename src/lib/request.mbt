///|
pub struct Request {
  headers : @immut/list.T[Header]
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
    headers,
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
pub(open) trait BodyReader {
  bytes(Self) -> FixedArray[Byte]!Error + Async
  text(Self) -> String!Error + Async
  json(Self) -> Json!Error + Async
}
