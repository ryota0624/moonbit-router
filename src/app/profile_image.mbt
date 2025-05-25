///|
type ProfileImageUrl String

//
///|
struct ProfileImageUploader[ExecutionContext] {
  upload : (ExecutionContext, UserId, ProfileImageUrl) -> Unit!Async + Error
}

///|
struct GcsExecutionContext {}

///|
struct GcsClient {}

///|
pub fn GcsClient::startExecutionContext(_ : GcsClient) -> GcsExecutionContext {
  return GcsExecutionContext::{  }
}

///|
pub fn GcsClient::new() -> GcsClient {
  return GcsClient::{  }
}

///|
pub fn profileImageUploaderOnGcs(
  client : GcsClient
) -> ProfileImageUploader[GcsExecutionContext] {
  ProfileImageUploader::{
    upload: fn(_, userId, url) {
      println(url._)
      // Implementation for uploading profile image to GCS
    },
  }
}

///|
trait UsesGcsClient {
  gcs(Self) -> GcsClient
}

///|
fn profileImageUploaderOnGcs2[Env : UsesGcsClient](
  env : Env
) -> ProfileImageUploader[GcsExecutionContext] {
  let _ = env.gcs()
  ProfileImageUploader::{
    upload: fn(_, userId, url) {
      println(url._)
      // Implementation for uploading profile image to GCS
    },
  }
}
