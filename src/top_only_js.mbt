///|
pub trait Request: Show {
  bytes(Self, callback : (Result[FixedArray[Byte], Error]) -> Unit) -> Unit
  text(Self, callback : (Result[String, Error]) -> Unit) -> Unit
  json(Self, callback : (Result[Json, Error]) -> Unit) -> Unit
  headers(Self) -> Headers
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
  response_headers : Headers
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
  ) -> Self
  builder() -> ResponseBuilder
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

///|
pub fn handle_greeting_callback(
  req : FetchApiRequest,
  callback : (FetchApiResponse) -> Unit
) -> Unit {
  handle_request(req, fn(response) { callback(response) })
}

///|
fn handle_request[Req : Request, Res : Response](
  req : Req,
  callback : (Res) -> Unit
) -> Unit {
  req.json(fn(result) {
    match result {
      Ok(bytes) => {
        println(req)
        println("JSON: " + bytes.stringify())
        let response = Res::builder()
          .status_code(201)
          .response_headers_add_all_from(req.headers())
          .json(AnyJsonData::{
            data: "Hello, world! from Moonbit",
            json: bytes,
            numbers: [23, 43, 0],
          })
        callback(response)
      }
      Err(err) =>
        callback(
          Res::builder()
          .status_code(500)
          .response_headers_add_all_from(req.headers())
          .text("Error: " + err.to_string()),
        )
    }
  })
}

///|
priv struct AnyJsonData {
  data : String
  numbers : Array[Int]
  json : Json
} derive(FromJson, ToJson, Eq, Show)

///|
extern type AnyValue

///|
pub fn result_ok(value : AnyValue) -> Result[AnyValue, AnyValue] {
  return Ok(value)
}

///|
pub fn result_err(value : AnyValue) -> Result[AnyValue, AnyValue] {
  return Err(value)
}
