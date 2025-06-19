
pub async fn[R : @lib.BodyReader] handle_request_(
  _ : @lib.Request,
  _ : R
) -> @lib.Response raise {
  Ok(
    @lib.Response::from_string(
      "Hello, world!",
      status_code=200,
      response_headers=@immut/list.from_array([]),
    ),
  ).unwrap_or_error()
}

///|
pub fn[R : @lib.BodyReader] router() -> @lib.Router[R] {
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
pub async fn handle_request_by_router(
  router : @lib.Router[@adaptor.FetchApiRequest],
  req : @adaptor.FetchApiRequest
) -> @adaptor.FetchApiResponse raise {
  let response = router.process(req.request(), req)
  @adaptor.FetchApiResponse::from(response)
}

///|
pub async fn init_database() -> @database.SqliteDatabase raise {
  @database.SqliteDatabase::new("test.db", with_create=true)
}
