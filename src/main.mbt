///|
pub fn handle_request_[R : @lib.BodyReader](
  _ : @lib.Request,
  _ : R
) -> @lib.Response!Error + Async {
  Ok(
    @lib.Response::from_string(
      "Hello, world!",
      status_code=200,
      response_headers=@immut/list.from_array([]),
    ),
  ).unwrap_or_error!()
}

///|
pub fn router[R : @lib.BodyReader]() -> @lib.Router[R] {
  @lib.Router::new(
    pre_middleware=[
      @lib.request_logging_middleware(),
      @lib.BasicAuthMiddleware::new("admin", "admin").install(),
    ],
    post_middleware=[
      @lib.response_logging_middleware(),
      @lib.response_logging_middleware2(),
    ],
    [@lib.Route::new("*", ["*"], handle_request_)],
    @lib.default_error_handler(),
  )
}

///|
pub fn handle_fetch_router() -> @lib.Router[@adaptor.FetchApiRequest] {
  router()
}

///|
pub fn handle_request_by_router(
  router : @lib.Router[@adaptor.FetchApiRequest],
  req : @adaptor.FetchApiRequest
) -> @adaptor.FetchApiResponse!Error + Async {
  let response = router.process!(req.request(), req)
  @adaptor.FetchApiResponse::from(response)
}

///|
pub async fn init_database() -> @database.SqliteDatabase!Error + Async {
  @database.SqliteDatabase::new!("test.db", with_create=true)
}
