///|
extern type RawFetchApiRequest

///|
extern "js" fn headers(self : RawFetchApiRequest) -> RawFetchApiHeaders =
  #| (self) => self.headers

///|
extern "js" fn _stringPropertiy(
  self : RawFetchApiRequest,
  propertiyName : String
) -> String =
  #| (self, propertyName) => self[propertyName]

///|
extern "js" fn decodeText(array : FixedArray[Byte]) -> String =
  #| (array) => new TextDecoder().decode(array)

///|
extern "js" fn keepalive(self : RawFetchApiRequest) -> Bool =
  #| (self) => self.keepalive

///|
extern "js" fn bytes(
  self : RawFetchApiRequest,
  callback : (Result[FixedArray[Byte], Error]) -> Unit
) -> Unit =
  #| (self, callback) => self.bytes().then((b) => callback(ryota0624$hello$$result_ok(b))).catch((e) => callback(ryota0624$hello$$result_err(e)))

///|
priv type FetchApiRequest RawFetchApiRequest

///|
impl Request for FetchApiRequest with method_(self) -> String {
  self._._stringPropertiy("method")
}

///|
impl Request for FetchApiRequest with url(self) -> String {
  self._._stringPropertiy("url")
}

///|
impl Request for FetchApiRequest with referrer(self) -> String {
  self._._stringPropertiy("referrer")
}

///|
impl Request for FetchApiRequest with mode(self) -> String {
  self._._stringPropertiy("mode")
}

///|
impl Request for FetchApiRequest with destination(self) -> String {
  self._._stringPropertiy("destination")
}

///|
impl Request for FetchApiRequest with credentials(self) -> String {
  self._._stringPropertiy("credentials")
}

///|
impl Request for FetchApiRequest with integrity(self) -> String {
  self._._stringPropertiy("integrity")
}

///|
impl Request for FetchApiRequest with redirect(self) -> String {
  self._._stringPropertiy("redirect")
}

///|
impl Request for FetchApiRequest with referrerPolicy(self) -> String {
  self._._stringPropertiy("referrerPolicy")
}

///|
impl Request for FetchApiRequest with keepalive(self) -> Bool {
  self._.keepalive()
}

///|
impl Request for FetchApiRequest with headers(self) -> Headers {
  Headers::{ _entries: fn() { self._.headers().entries() } }
}

///|
impl Request for FetchApiRequest with bytes(self, callback) -> Unit {
  self._.bytes(callback)
}

///|
impl Request for FetchApiRequest with text(
  self,
  callback : (Result[String, Error]) -> Unit
) -> Unit {
  self._.bytes(fn(result) { result.map(decodeText) |> callback })
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
  let msg = "Request { method: " +
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
pub extern type RawFetchApiHeaders

///|
extern "js" fn _entries(self : RawFetchApiHeaders) -> Array[Array[String]] =
  #| (self) => Array.from(self.entries())

///|
fn RawFetchApiHeaders::entries(self : RawFetchApiHeaders) -> Array[Header] {
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
  status_code : Int,
  response_header : Array[Header]
) {
  FetchApiResponse::from_string(body, status_code, response_header)
}
