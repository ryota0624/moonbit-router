///|
pub fn handle_greeting_callback(
  req : FetchApiRequest,
  callback : (FetchApiResponse) -> Unit
) -> Unit {
  handle_request(req, fn(response) { callback(response) })
}

///|
fn response_any_json_data_route[Req : Request, Res : Response]() ->
     Route[Req, Res] {
  let route = Route::new(response_any_json_data)
    .add_middleware(BasicAuthMiddleware::new("admin", "password").install())
    .add_middleware(request_logging_middleware())
    .add_middleware(request_url_logging_middleware())
  return route
}

///|
fn handle_request[Req : Request, Res : Response](
  req : Req,
  callback : (Res) -> Unit
) -> Unit {
  response_any_json_data_route().handle(req, callback)
}

///|
fn response_any_json_data[Req : Request, Res : Response](
  req : Req,
  callback : (Res) -> Unit
) -> Unit {
  match req.method_() {
    "GET" => {
      let response = Res::builder()
        .status_code(200)
        .response_headers_add_all_from(req.headers())
        .text("Hello, world! from Moonbit")
      callback(response)
    }
    "POST" =>
      req.json(fn(result) {
        match result {
          Ok(json) => {
            println(req)
            println("JSON: " + json.stringify())
            let response = Res::builder()
              .status_code(201)
              .response_headers_add_all_from(req.headers())
              .json(AnyJsonData::{
                data: "Hello, world! from Moonbit",
                json,
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
    _ =>
      callback(
        Res::builder()
        .status_code(405)
        .response_headers_add_all_from(req.headers())
        .text("Method not allowed"),
      )
  }
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
