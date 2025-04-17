import { Hono } from 'hono'
import * as M from "../../../target/js/release/build/hello";
import { prettyJSON } from 'hono/pretty-json'

const app = new Hono()

app.use(prettyJSON())
app.get('/', (c) => {
  M.greeting_later((word) => {
    console.log("Hello " + word);
  })
  return M.handle_greeting(c)
})

console.log("Server is running on http://localhost:3000")

export default app