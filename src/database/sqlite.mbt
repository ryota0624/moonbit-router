///|
pub fn cos(d : Double) -> Double = "Math" "cos"

///|
#external
pub type SqliteDatabase

///|
#external
pub type DatabaseStatement

///|
pub struct DatabaseStatementParameter {
  name : String
  value : String
}

///|
#external
pub type ResultSet

///|
extern "js" fn ResultSet::_asJsonString(self : ResultSet) -> String =
  #| (self) => JSON.stringify(self)

///|
pub fn ResultSet::asJson(self : ResultSet) -> Json raise @json.ParseError {
  @json.parse(self._asJsonString())
}

///|
pub fn[To : @json.FromJson] ResultSet::cast(self : ResultSet) -> To raise Error {
  @json.from_json(self.asJson())
}

///|
extern "js" fn DatabaseStatement::_all(
  self : DatabaseStatement,
  resolve : (Array[ResultSet]) -> Unit,
  reject : (Error) -> Unit
) -> Unit =
  #| (self) => self.all().then(resolve).catch(reject)

///|
extern "js" fn DatabaseStatement::_get(
  self : DatabaseStatement,
  resolve : (ResultSet) -> Unit,
  reject : (Error) -> Unit
) -> Unit =
  #| (self) => self.get().then(resolve).catch(reject)

///|
extern "js" fn DatabaseStatement::_run(
  self : DatabaseStatement,
  resolve : (Unit) -> Unit,
  reject : (Error) -> Unit
) -> Unit =
  #| (self) => self.run().then(resolve).catch(reject)

///|
extern "js" fn DatabaseStatement::finalize(self : DatabaseStatement) -> Unit =
  #| (self) => self.finalize()

///|
extern "js" fn database(
  initialize : String,
  as_readonly~ : Bool,
  with_create~ : Bool,
  strict~ : Bool,
  resolve : (SqliteDatabase) -> Unit,
  reject : (Error) -> Unit
) -> Unit =
  #|(initialize, readonly, create, strict, resolve, reject) => {
  #|  return import("bun:sqlite").then((mod) => new mod.Database(initialize, {readonly: readonly, create: create, strict: strict})).then(resolve).catch(reject);
  #|}

///|
pub async fn SqliteDatabase::new(
  initialize : String,
  as_readonly~ : Bool = false,
  with_create~ : Bool = false,
  strict~ : Bool = false
) -> SqliteDatabase raise {
  suspend(fn(resolve, reject) {
    database(initialize, as_readonly~, with_create~, strict~, resolve, reject)
  })
}

///|
pub async fn SqliteDatabase::all(
  self : DatabaseStatement
) -> Array[ResultSet] raise {
  suspend(fn(resolve, reject) { self._all(resolve, reject) })
}

///|
pub async fn SqliteDatabase::get(self : DatabaseStatement) -> ResultSet raise {
  suspend(fn(resolve, reject) { self._get(resolve, reject) })
}

///|
pub async fn SqliteDatabase::run(self : DatabaseStatement) -> Unit raise {
  suspend(fn(resolve, reject) { self._run(resolve, reject) })
}

///|
test {
  let number = "\"123\""
  let parsed_number = @json.parse(number)
  println(parsed_number)
}
