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