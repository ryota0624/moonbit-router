///|
async fn suspend[T, E : Error](f : ((T) -> Unit, (E) -> Unit) -> Unit) -> T!E = "%async.suspend"

///|
fn run_async(f : () -> Unit!Async) -> Unit = "%async.run"
