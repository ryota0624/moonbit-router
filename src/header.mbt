///|
pub struct Header {
  name : String
  value : String
} derive(Eq, Show)

///|
trait Headers {
  entries(Self) -> Array[Header]
  get(Self, name : String) -> String?
}

