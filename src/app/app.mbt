///|
struct App {
  register_user_use_case : RegisterUserUseCase[
    SqliteExecutionContext,
    GcsExecutionContext,
  ]
}

///|
struct AppEnv {
  _sqlite : SqliteDatabase
  _gcs : GcsClient
}

///|
impl UsesSqliteDatabase for AppEnv with sqlite(self : AppEnv) -> SqliteDatabase {
  self._sqlite
}

///|
impl UsesGcsClient for AppEnv with gcs(self : AppEnv) -> GcsClient {
  self._gcs
}

///|
fn App::new() -> App!Async {
  let sqlite = SqliteDatabase::new()
  let user_repository = userRepositoryOnSqlite(sqlite)
  let gcs = GcsClient::new()
  let profile_image_uploader = profileImageUploaderOnGcs(gcs)
  let use_case = RegisterUserUseCase::new(
    user_repository, profile_image_uploader,
  )
  let _ = use_case.execute?(
    AppCtx::{
      db_ctx: sqlite.startExecutionContext(),
      gcs_ctx: gcs.startExecutionContext(),
    },
    User::{ id: "", name: "John Doe", email: "john.doe@example.com" },
    "http://example.com/profile.jpg",
  )
  App::{ register_user_use_case: use_case }
}

///|
fn App::new2(env : AppEnv) -> App {
  let user_repository = userRepositoryOnSqlite2(env)
  let profile_image_uploader = profileImageUploaderOnGcs2(env)
  let use_case = RegisterUserUseCase::new(
    user_repository, profile_image_uploader,
  )
  App::{ register_user_use_case: use_case }
}

///|
struct RegisterUserUseCase[UseRepositoryCtx, ProfileImageUploaderCtx] {
  user_repository : UserRepository[UseRepositoryCtx]
  profile_image_uploader : ProfileImageUploader[ProfileImageUploaderCtx]
}

///|
pub fn RegisterUserUseCase::new[UseRepositoryCtx, ProfileImageUploaderCtx](
  user_repository : UserRepository[UseRepositoryCtx],
  profile_image_uploader : ProfileImageUploader[ProfileImageUploaderCtx]
) -> RegisterUserUseCase[UseRepositoryCtx, ProfileImageUploaderCtx] {
  return RegisterUserUseCase::{ user_repository, profile_image_uploader }
}

///|
struct AppCtx {
  db_ctx : SqliteExecutionContext
  gcs_ctx : GcsExecutionContext
}

///|
pub fn RegisterUserUseCase::execute(
  self : RegisterUserUseCase[SqliteExecutionContext, GcsExecutionContext],
  ctx : AppCtx,
  user : User,
  profile_image_url : ProfileImageUrl
) -> Unit!Async + Error {
  let exists = (self.user_repository.get_user_by_id)!(ctx.db_ctx, user.id)
  guard exists is None else { return fail!("User already exists") }
  (self.user_repository.store)!(ctx.db_ctx, user)
  (self.profile_image_uploader.upload)!(ctx.gcs_ctx, user.id, profile_image_url)
  Ok(()).unwrap_or_error!()
}
