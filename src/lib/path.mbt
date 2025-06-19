///|
type Path String

///|
fn Path::new(path : String) -> Path {
  return path
}

///|
fn Path::from_url(url : String) -> Path? {
  url
  .split("://")
  .to_array()
  .get(1)
  .map(fn { value => value.to_string() })
  .map(Path::new)
}

///|
fn path(request : Request) -> Path raise {
  guard Path::from_url(request.url) is Some(path) else { fail("Invalid URL") }
  path
}
