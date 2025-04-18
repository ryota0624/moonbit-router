test "hello" {
  println("あ".to_array().map(Char::to_int));
  println("あ".to_array());
  println("あ".to_bytes().to_array());

  if @lib.hello() != "Hello, world!" {
    fail!("@lib.hello() != \"Hello, world!\"")
  }
}
