///|
extern type FetchApiRequest

///|
extern "js" fn headers(self : FetchApiRequest) -> FetchApiHeaders =
  #| (self) => self.headers

///|
extern "js" fn _stringPropertiy(
  self : FetchApiRequest,
  propertiyName : String
) -> String =
  #| (self, propertyName) => self[propertyName]

///|
extern "js" fn decodeText(array : FixedArray[Byte]) -> String =
  #| (array) => new TextDecoder().decode(array)

///|
extern "js" fn keepalive(self : FetchApiRequest) -> Bool =
  #| (self) => self.keepalive

///|
extern "js" fn bytes(
  self : FetchApiRequest,
  callback : (Result[FixedArray[Byte], Error]) -> Unit
) -> Unit =
  #| (self, callback) => self.bytes().then((b) => callback(ryota0624$hello$$result_ok(b))).catch((e) => callback(ryota0624$hello$$result_err(e)))

///|
///|
impl Request for FetchApiRequest with method_(self) -> String {
  self._stringPropertiy("method")
}

///|
impl Request for FetchApiRequest with url(self) -> String {
  self._stringPropertiy("url")
}

///|
impl Request for FetchApiRequest with referrer(self) -> String {
  self._stringPropertiy("referrer")
}

///|
impl Request for FetchApiRequest with mode(self) -> String {
  self._stringPropertiy("mode")
}

///|
impl Request for FetchApiRequest with destination(self) -> String {
  self._stringPropertiy("destination")
}

///|
impl Request for FetchApiRequest with credentials(self) -> String {
  self._stringPropertiy("credentials")
}

///|
impl Request for FetchApiRequest with integrity(self) -> String {
  self._stringPropertiy("integrity")
}

///|
impl Request for FetchApiRequest with redirect(self) -> String {
  self._stringPropertiy("redirect")
}

///|
impl Request for FetchApiRequest with referrerPolicy(self) -> String {
  self._stringPropertiy("referrerPolicy")
}

///|
impl Request for FetchApiRequest with keepalive(self) -> Bool {
  self.keepalive()
}

///|
impl Request for FetchApiRequest with headers(self) -> Headers {
  Headers::{ _entries: fn() { self.headers().entries() } }
}

///|
impl Request for FetchApiRequest with bytes(self, callback) -> Unit {
  self.bytes(callback)
}

///|
impl Request for FetchApiRequest with text(
  self,
  callback : (Result[String, Error]) -> Unit
) -> Unit {
  self.bytes(fn(result) { result.map(decodeText) |> callback })
}

///|
impl Request for FetchApiRequest with json(
  self : FetchApiRequest,
  callback : (Result[Json, Error]) -> Unit
) -> Unit {
  self.text(fn(result) {
    let jsonValue = result.bind(fn(text) {
      @json.parse?(text).map_err(fn(err) { err })
    })
    callback(jsonValue)
  })
}

///|
impl Show for FetchApiRequest with output(self, logger) {
  let keepalive = if self.keepalive() { "true" } else { "false" }
  let headers = self
    .headers()
    .entries()
    .map(fn(h) { return h.name + ": " + h.value })
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
priv extern type FetchApiHeaders

///|
extern "js" fn _entries(self : FetchApiHeaders) -> Array[Array[String]] =
  #| (self) => Array.from(self.entries())

///|
fn FetchApiHeaders::entries(self : FetchApiHeaders) -> Array[Header] {
  return self._entries().map(fn(entry) { { name: entry[0], value: entry[1] } })
}

///|
extern type FetchApiResponse

///|
extern "js" fn FetchApiResponse::from_string(
  body : String,
  status_code : Int,
  response_header : Array[Header]
) -> FetchApiResponse =
  #| (body, status_code, response_header) => {
  #|    const headers = Object.fromEntries(new Map(response_header.map(h => [h.name, h.value])));
  #|    return new Response(body, { status: status_code, headers: headers });
  #|  }

///|
impl Response for FetchApiResponse with new_from_string(
  body : String,
  status_code~ : Int,
  response_headers~ : Array[Header]
) {
  FetchApiResponse::from_string(body, status_code, response_headers)
}
  