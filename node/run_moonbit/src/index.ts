import * as M from "../../../target/js/release/build/router";

const router = M.handle_fetch_router();
Bun.serve({
    fetch: async (req) => {
        return new Promise<any>((resolve) => {
            M.handle_request_by_router(router, req, (response) => {
                resolve(response);
            }, (err) => {
                console.error("Error:", err);
                resolve(new Response("Internal Server Error", { status: 500 }));
            });
        })
    },
});