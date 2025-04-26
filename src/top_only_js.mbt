///|
pub fn handle_fetch_api_request(
  req : FetchApiRequest
) -> FetchApiResponse!Error + Async {
  handle_request!(req)
}

///|
fn handle_js_request_router[Req : Request, Res : Response]() -> Router[Req, Res] {
  let route = Router::new(
    [
      BasicAuthMiddleware::new("admin", "password").install(),
      request_logging_middleware(),
      request_url_logging_middleware(),
    ],
    [Route::fromSafeHandler("*", ["*"], response_any_json_data_async)],
    default_error_handler(),
  )
  return route
}

///|
async fn handle_request[Req : Request, Res : Response](
  req : Req
) -> Res!Error + Async {
  handle_js_request_router().process!(req)
}

///|
async fn response_any_json_data_async[Req : Request, Res : Response](
  req : Req
) -> Res {
  match req.method_() {
    "GET" =>
      Res::builder()
      .status_code(200)
      .response_headers_add_all_from(req.headers())
      .text("Hello, world! from Moonbit")
    "POST" =>
      match req.json?() {
        Ok(json) => {
          println(req)
          println("JSON: " + json.stringify())
          Res::builder()
          .status_code(201)
          .response_headers_add_all_from(req.headers())
          .json(AnyJsonData::{
            data: "Hello, world! from Moonbit",
            json,
            numbers: [23, 43, 0],
          })
        }
        Err(err) =>
          Res::builder()
          .status_code(500)
          .response_headers_add_all_from(req.headers())
          .text("Error: " + err.to_string())
      }
    _ =>
      Res::builder()
      .status_code(405)
      .response_headers_add_all_from(req.headers())
      .text("Method not allowed")
  }
}

///|
priv struct AnyJsonData {
  data : String
  numbers : Array[Int]
  json : Json
} derive(FromJson, ToJson, Eq, Show)
