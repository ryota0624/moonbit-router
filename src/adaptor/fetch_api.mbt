///|
#external
pub type FetchApiRequest

///|
pub fn FetchApiRequest::request(self : FetchApiRequest) -> @lib.Request {
  @lib.Request::new(
    method_=self.method_(),
    headers=self.headers(),
    url=self.url(),
    referrer=self.referrer(),
    mode=self.mode(),
    destination=self.destination(),
    credentials=self.credentials(),
    integrity=self.integrity(),
    keepalive=self.keepalive(),
    redirect=self.redirect(),
    referrerPolicy=self.referrerPolicy(),
  )
}

///|
pub impl @lib.BodyReader for FetchApiRequest with bytes(self : FetchApiRequest) -> FixedArray[
  Byte,
] raise {
  suspend(fn(resolve, reject) { self.js_response_bytes(resolve, reject) })
}

///|
pub impl @lib.BodyReader for FetchApiRequest with text(self : FetchApiRequest) -> String raise {
  suspend(fn(resolve, reject) { self.js_response_text(resolve, reject) })
}

///|
pub impl @lib.BodyReader for FetchApiRequest with json(self : FetchApiRequest) -> Json raise {
  @json.parse(self.text())
}

///|
extern "js" fn _headers(self : FetchApiRequest) -> FetchApiHeaders =
  #| (self) => self.headers

///|
extern "js" fn _stringPropertiy(
  self : FetchApiRequest,
  propertiyName : String
) -> String =
  #| (self, propertyName) => self[propertyName]

///|
extern "js" fn keepalive(self : FetchApiRequest) -> Bool =
  #| (self) => self.keepalive

///|
extern "js" fn js_response_bytes(
  self : FetchApiRequest,
  resolve : (FixedArray[Byte]) -> Unit,
  reject : (Error) -> Unit
) -> Unit =
  #| (self, resolve, reject) => self.bytes().then(resolve).catch(reject)

///|
extern "js" fn js_response_text(
  self : FetchApiRequest,
  resolve : (String) -> Unit,
  reject : (Error) -> Unit
) -> Unit =
  #| (self, resolve, reject) => self.text().then(resolve).catch(reject)

///|

///|
fn method_(self : FetchApiRequest) -> String {
  self._stringPropertiy("method")
}

///|
fn headers(self : FetchApiRequest) -> @immut/list.T[@lib.Header] {
  @immut/list.from_array(
    self
    ._headers()
    ._entries()
    .map(fn(entry) { @lib.Header::new(name=entry[0], value=entry[1]) }),
  )
}

///|
fn url(self : FetchApiRequest) -> String {
  self._stringPropertiy("url")
}

///|
fn referrer(self : FetchApiRequest) -> String {
  self._stringPropertiy("referrer")
}

///|
fn mode(self : FetchApiRequest) -> String {
  self._stringPropertiy("mode")
}

///|
fn destination(self : FetchApiRequest) -> String {
  self._stringPropertiy("destination")
}

///|
fn credentials(self : FetchApiRequest) -> String {
  self._stringPropertiy("credentials")
}

///|
fn integrity(self : FetchApiRequest) -> String {
  self._stringPropertiy("integrity")
}

///|
fn redirect(self : FetchApiRequest) -> String {
  self._stringPropertiy("redirect")
}

///|
fn referrerPolicy(self : FetchApiRequest) -> String {
  self._stringPropertiy("referrerPolicy")
}

///|
impl Show for FetchApiRequest with output(self, logger) {
  let keepalive = if self.keepalive() { "true" } else { "false" }
  let headers = self
    .headers()
    .map(fn(h) { return h.name + ": " + h.value })
    .to_array()
    .join(", ")
  let msg = "FetchApiRequest { method: " +
    self.method_() +
    ", url: " +
    self.url() +
    ", referrer: " +
    self.referrer() +
    ", mode: " +
    self.mode() +
    ", destination: " +
    self.destination() +
    ", credentials: " +
    self.credentials() +
    ", integrity: " +
    self.integrity() +
    ", keepalive: " +
    keepalive +
    ", redirect: " +
    self.redirect() +
    ", referrerPolicy: " +
    self.referrerPolicy() +
    ", headers: [" +
    headers +
    "] }"
  logger.write_string(msg)
}

///|
#external
priv type FetchApiHeaders

///|
extern "js" fn _entries(self : FetchApiHeaders) -> Array[Array[String]] =
  #| (self) => Array.from(self.entries())

///|
#external
pub type FetchApiResponse

///|
impl Show for FetchApiResponse with output(_, logger) {
  logger.write_string("FetchApiResponse instance")
}

///|
pub fn FetchApiResponse::from(response : @lib.Response) -> FetchApiResponse {
  match response.body {
    ArrayBuffer(raw) =>
      FetchApiResponse::from_bytes(
        raw,
        response.status_code,
        response.response_headers.to_array(),
      )
    String(raw) =>
      FetchApiResponse::from_string(
        raw,
        response.status_code,
        response.response_headers.to_array(),
      )
    Json(raw) =>
      FetchApiResponse::from_string(
        raw.stringify(),
        response.status_code,
        response.response_headers.to_array(),
      )
    None =>
      FetchApiResponse::from_string(
        "",
        response.status_code,
        response.response_headers.to_array(),
      )
  }
}

///|
pub impl @lib.ResponseWriter for FetchApiResponse with write(
  response : @lib.Response
) -> &@lib.RawResponse {
  FetchApiResponse::from(response)
}

///|
extern "js" fn FetchApiResponse::from_string(
  body : String,
  status_code : Int,
  response_header : Array[@lib.Header]
) -> FetchApiResponse =
  #| (body, status_code, response_header) => {
  #|    const headers = Object.fromEntries(new Map(response_header.map(h => [h.name, h.value])));
  #|    return new Response(body, { status: status_code, headers: headers });
  #|  }

///|
extern "js" fn FetchApiResponse::from_bytes(
  body : Bytes,
  status_code : Int,
  response_header : Array[@lib.Header]
) -> FetchApiResponse =
  #| (body, status_code, response_header) => {
  #|    const headers = Object.fromEntries(new Map(response_header.map(h => [h.name, h.value])));
  #|    return new Response(body, { status: status_code, headers: headers });
  #|  }
