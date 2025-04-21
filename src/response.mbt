///|
struct ResponseBuilder {
  status_code : Int
  response_headers : Array[Header]
}

///|
fn status_code(self : ResponseBuilder, status_code : Int) -> ResponseBuilder {
  ResponseBuilder::{ status_code, response_headers: self.response_headers }
}

///|
fn response_headers(
  self : ResponseBuilder,
  response_headers : Array[Header]
) -> ResponseBuilder {
  ResponseBuilder::{ status_code: self.status_code, response_headers }
}

///|
fn response_headers_add(
  self : ResponseBuilder,
  response_header : Header
) -> ResponseBuilder {
  ResponseBuilder::{
    status_code: self.status_code,
    response_headers: [response_header] + self.response_headers,
  }
}

///|
fn response_headers_add_all(
  self : ResponseBuilder,
  response_headers : Array[Header]
) -> ResponseBuilder {
  ResponseBuilder::{
    status_code: self.status_code,
    response_headers: response_headers + self.response_headers,
  }
}

///|
fn response_headers_add_all_from(
  self : ResponseBuilder,
  response_headers : &Headers
) -> ResponseBuilder {
  ResponseBuilder::{
    status_code: self.status_code,
    response_headers: response_headers.entries() + self.response_headers,
  }
}

///|
fn raw_json[T : Response](self : ResponseBuilder, json : Json) -> T {
  Response::new_from_json(
    json,
    status_code=self.status_code,
    response_headers=self.response_headers,
  )
}

///|
fn json[T : Response, Payload : ToJson](
  self : ResponseBuilder,
  payload : Payload
) -> T {
  Response::new_from_json(
    payload.to_json(),
    status_code=self.status_code,
    response_headers=self.response_headers,
  )
}

///|
fn text[T : Response](self : ResponseBuilder, text : String) -> T {
  Response::new_from_string(
    text,
    status_code=self.status_code,
    response_headers=self.response_headers,
  )
}

///|
pub trait Response {
  new_from_string(
    body : String,
    status_code~ : Int,
    response_headers~ : Array[Header],
  ) -> Self
  new_from_json(
    body : Json,
    status_code~ : Int,
    response_headers~ : Array[Header],
  ) -> Self = _
  builder() -> ResponseBuilder = _
}

///|
impl Response with new_from_json(
  body : Json,
  status_code~ : Int,
  response_headers~ : Array[Header]
) -> Self {
  Response::new_from_string(
    body.stringify(),
    status_code~,
    response_headers=[
        { name: "Content-Type", value: "application/json" },
        ..response_headers,
      ],
  )
}

///|
impl Response with builder() -> ResponseBuilder {
  ResponseBuilder::{ status_code: 200, response_headers: [] }
}
