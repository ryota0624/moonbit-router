///|
extern type FetchApiRequest

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
impl Request for FetchApiRequest with headers(self) -> &Headers {
  self._headers()
}

///|
impl Request for FetchApiRequest with bytes(self) -> FixedArray[Byte]!Error +
Async {
  suspend!(fn(resolve, reject) { 
    self.js_response_bytes(resolve, reject)
  })
}

///|
impl Request for FetchApiRequest with text(self) -> String!Error + Async {
    suspend!(fn(resolve, reject) { 
    self.js_response_text(resolve, reject)
  })
}

///|
impl Request for FetchApiRequest with json(self : FetchApiRequest) -> Json!Error +
Async {
  @json.parse?(self.text!()).unwrap_or_error!()
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
impl Headers for FetchApiHeaders with entries(self : FetchApiHeaders) -> Array[
  Header,
] {
  return self._entries().map(fn(entry) { { name: entry[0], value: entry[1] } })
}

///|
impl Headers for FetchApiHeaders with get(self : FetchApiHeaders, name : String) -> String? {
  let entries = self.entries()
  let entry = entries.filter(fn(e) { e.name == name })
  if entry.length() == 0 {
    return None
  } else {
    return Some(entry[0].value)
  }
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
