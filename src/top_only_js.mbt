///|
pub fn handle_fetch_api_request(
  req : FetchApiRequest,
  callback : (FetchApiResponse) -> Unit
) -> Unit {
  handle_request(req, fn(response) { callback(response) })
}

///|
fn handle_js_request_router[Req : Request, Res : Response]() -> Router[Req, Res] {
  let route = Router::new(
    [
      BasicAuthMiddleware::new("admin", "password").install(),
      request_logging_middleware(),
      request_url_logging_middleware(),
    ],
    [Route::newFromResult("*", ["*"], response_any_json_data)],
    default_error_handler(),
  )
  return route
}

///|
fn handle_request[Req : Request, Res : Response](
  req : Req,
  callback : (Res) -> Unit
) -> Unit {
  handle_js_request_router().process(req, callback)
}

///|
fn response_any_json_data[Req : Request, Res : Response](
  req : Req,
  callback : (Res) -> Unit
) -> Result[Unit, Error] {
  match req.method_() {
    "GET" => {
      let response = Res::builder()
        .status_code(200)
        .response_headers_add_all_from(req.headers())
        .text("Hello, world! from Moonbit")
      callback(response)
      return Ok(())
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
  return Ok(())
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
