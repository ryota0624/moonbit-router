///|
pub struct Header {
  name : String
  value : String
} derive(Eq, Show)

pub fn Header::new(name~ : String, value~ : String) -> Header {
  Header::{
    name,
    value,
  }
}