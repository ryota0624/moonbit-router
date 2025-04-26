import * as M from "../../../target/js/release/build/router";

Bun.serve({
    fetch: async (req) => {
        return new Promise<any>((resolve) => {
            M.handle_fetch_api_request(req, (response) => {
                resolve(response);
            }, (err) => {
                console.error("Error:", err);
                resolve(new Response("Internal Server Error", { status: 500 }));
            });
        })
    },
});