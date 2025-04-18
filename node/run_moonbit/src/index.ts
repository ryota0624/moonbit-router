import * as M from "../../../target/js/release/build/hello";

Bun.serve({
    fetch: async (req) => {
        return new Promise<any>((resolve) => {
            M.handle_greeting_callback(req, (response) => {
                resolve(response);
            });
        })
    },
});