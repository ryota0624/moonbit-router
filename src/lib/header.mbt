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

///|
test "Headers#get Header名の一致するHeaderを取得できる" {
  let headers = Headers::new(
    @immut/list.from_array([
      Header::new(name="Content-Type", value="application/json"),
      Header::new(name="Authorization", value="Bearer token"),
    ]),
  )
  let header = headers.get("Authorization")
  assert_eq(header, Some("Bearer token"))
  let missing_header = headers.get("Missing-Header")
  assert_eq(missing_header, None)
}
