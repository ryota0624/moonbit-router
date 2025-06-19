///|
pub struct Response {
  status_code : Int
  response_headers : @immut/list.T[Header]
  body : ResponseBody
} derive(Show)

///|
pub fn Response::from_string(
  body : String,
  status_code~ : Int,
  response_headers~ : @immut/list.T[Header]
) -> Response {
  Response::{ status_code, response_headers, body: ResponseBody::String(body) }
}

///|
pub enum ResponseBody {
  String(String)
  Json(Json)
  ArrayBuffer(Bytes)
  None
} derive(Show)

///|
pub(open) trait ResponseWriter {
  write(response : Response) -> &RawResponse
}

///|
pub(open) trait RawResponse: Show {}
