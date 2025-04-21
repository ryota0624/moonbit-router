import * as M from "../../../target/js/release/build/hello";

Bun.serve({
    fetch: async (req) => {
        return new Promise<any>((resolve) => {
            M.handle_fetch_api_request(req, (response) => {
                resolve(response);
            });
        })
    },
});