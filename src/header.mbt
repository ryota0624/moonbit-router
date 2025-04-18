///|
pub struct Header {
  name : String
  value : String
} derive(Eq, Show)

///|
struct Headers {
  _entries : () -> Array[Header]
}

///|
fn entries(self : Headers) -> Array[Header] {
  return (self._entries)()
}