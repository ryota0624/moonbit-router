///|
struct UserRepository[ExecutionContext] {
  get_user_by_id : (ExecutionContext, UserId) -> User?!Async + Error
  store : (ExecutionContext, User) -> Unit!Async + Error
}

pub fn UserRepository::withContext[From, To](
  self : UserRepository[From],
  context_mapping : (To) -> From
) -> UserRepository[To] {
  UserRepository::{
    get_user_by_id: fn(ctx, id) {
      (self.get_user_by_id)!(context_mapping(ctx), id)
    },
    store: fn(ctx, user) {
      (self.store)!(context_mapping(ctx), user)
    },
  }
}

///|
struct SqliteExecutionContext {}

///|
struct SqliteDatabase {} derive(Show)

///|
pub fn SqliteDatabase::startExecutionContext(
  _ : SqliteDatabase
) -> SqliteExecutionContext {
  return SqliteExecutionContext::{  }
}

///|
fn SqliteDatabase::new() -> SqliteDatabase {
  return SqliteDatabase::{  }
}

///| 
fn userRepositoryOnSqlite(
  db : SqliteDatabase
) -> UserRepository[SqliteExecutionContext] {
  return UserRepository::{
    get_user_by_id: fn(_, id) {
      println(db)
      // Implementation for getting user by ID from SQLite
      Some(User::{ id, name: "John Doe", email: "john.doe@example.com" })
    },
    store: fn(_, _) {
      // Implementation for storing user in SQLite

    },
  }
}

trait UsesSqliteDatabase {
  sqlite(Self) -> SqliteDatabase
}
///| 
fn userRepositoryOnSqlite2[Env: UsesSqliteDatabase](
  env : Env
) -> UserRepository[SqliteExecutionContext] {
  let db = env.sqlite()
  return UserRepository::{
    get_user_by_id: fn(_, id) {
      println(db)
      // Implementation for getting user by ID from SQLite
      Some(User::{ id, name: "John Doe", email: "john.doe@example.com" })
    },
    store: fn(_, _) {
      // Implementation for storing user in SQLite

    },
  }
}