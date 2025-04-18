///|
pub trait Request {
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
pub trait Response {
  new_from_string(
    body : String,
    status_code : Int,
    response_header : Array[Header],
  ) -> Self
  new_from_json(
    body : Json,
    status_code~ : Int,
    response_header~ : Array[Header],
  ) -> Self
}

///|
impl Response with new_from_json(
  body : Json,
  status_code~ : Int,
  response_header~ : Array[Header]
) -> Self {
  Response::new_from_string(
    body.stringify(),
    status_code,
    [..response_header, { name: "Content-Type", value: "application/json" }],
  )
}

///|
pub fn handle_greeting_callback(
  req : RawFetchApiRequest,
  callback : (FetchApiResponse) -> Unit
) -> Unit {
  handle_fetch_api_request(FetchApiRequest(req), fn(response) {
    callback(response)
  })
}

///|
fn handle_fetch_api_request(
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
        println("JSON: " + bytes.stringify())
        let response = Res::new_from_json(
          AnyJsonData::{
            data: "Hello, world! from Moonbit",
            json: bytes,
            numbers: [23, 43, 0],
          }.to_json(),
          status_code=201,
          response_header=[
              { name: "X-My-Header", value: "Hello, d!" },
              ..req
              .headers()
              .entries()
              .map(fn(h) {
                {
                  name: "Echo-Header-" + h.name,
                  value: h.value + " from Moonbit",
                }
              }),
            ],
        )
        callback(response)
      }
      Err(err) =>
        callback(Res::new_from_string("Error: " + err.to_string(), 500, []))
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
