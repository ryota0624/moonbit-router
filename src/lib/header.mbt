///|
pub struct Header {
  name : String
  value : String
} derive(Eq, Show)

///|
pub fn Header::new(name~ : String, value~ : String) -> Header {
  Header::{ name, value }
}

///|
pub struct Headers {
  priv headers : @immut/list.T[Header]
} derive(Show)

///|
pub fn Headers::new(headers : @immut/list.T[Header]) -> Headers {
  Headers::{ headers, }
}

///|
pub fn Headers::entries(self : Headers) -> @immut/list.T[Header] {
  self.headers
}

///|
pub fn Headers::get(self : Headers, name : String) -> String? {
  self.headers
  .find(fn(header) { header.name == name })
  .map(fn(header) { header.value })
}
