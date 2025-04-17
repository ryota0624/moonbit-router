///|
priv extern type JSTimer

// TODO: web標準のreq/resを扱えるようにする

///|
// extern "js" fn text(self : Request, text : String) -> HonoResponse =
//   #|(self, text) => self.text(text)

// ///|
// extern "js" fn invokeHonoContextMethod(
//   self : Request,
//   methodCall : String,
//   param : String
// ) -> HonoResponse =
//   #|(self, methodCall, param) => self[methodCall](param)

// ///|
// extern "js" fn invokeHonoContextMethodWithJson(
//   self : Request,
//   methodCall : String,
//   param : Json
// ) -> HonoResponse =
//   #|(self, methodCall, param) => self[methodCall](param)

// struct WrappedHonoRequestContext {
//   request: HonoRequestContext
// }

///|
// extern "js" fn json(
//   self : Request,
//   methodCall : String,
//   param : String
// ) -> HonoResponse =
//   #|(self, methodCall, param) => self[methodCall](JSON.parse(param))

// ///|
// extern "js" fn json2(
//   self : Request,
//   methodCall : String,
//   param : AnyJsonData
// ) -> HonoResponse =
//   #|(self, methodCall, param) => self[methodCall](param)

// ///|
// fn json3(
//   self : Request,
//   methodCall : String,
//   param : AnyJsonData
// ) -> HonoResponse {
//   self.json2(methodCall, param)
// }

///|
struct Replay {
  response : Int
}

extern type Request

///|
extern type Response


struct HttpHeader {
  name : String
  value : String
}
///|
extern "js" fn new_response_from_string(body : String, status_code: Int, response_header: Array[HttpHeader]) -> Response =
  #| (body, status_code, response_header) => {
  #|    const headers = Object.fromEntries(new Map(response_header.map(h => [
  #|h.name, h.value])));
  #|    return new Response(body, { status: status_code, headers: headers });
  #|  }

///|
fn new_json_response(body : Json, status_code~: Int = 200, response_header~: Array[HttpHeader] = []) -> Response {
  new_response_from_string(body.stringify(), status_code, response_header)
}

/// pub fn wrapHonoRequestContext(helloRequest: HonoRequestContext) -> WrappedHonoRequestContext {
///   WrappedHonoRequestContext::{ request: helloRequest }
/// }

///|
extern "js" fn js_set_timeout(f : () -> Unit, duration : Int) -> JSTimer =
  #| (f, duration) => setTimeout(f, duration)

///|
pub fn greeting() -> Unit {
  println(@lib.hello())
}

///|
pub fn greeting_later(callback : (String) -> Unit) -> Unit {
  let _ = js_set_timeout(fn() { callback(@lib.hello()) }, 1000)

}

///|
pub fn handle_greeting(req : Request) -> Response {
  new_json_response(
    AnyJsonData::{ data: "Hello, world! from Moonbit", numbers: [23, 43, 0] }.to_json(),
    status_code = 201,
    response_header = [
      { name: "Content-Type", value: "application/json" },
      { name: "X-My-Header", value: "Hello, d!" }
    ]
  )
}

///|
priv struct AnyJsonData {
  data : String
  numbers : Array[Int]
} derive(FromJson, ToJson, Eq, Show)
