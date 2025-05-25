import * as MyMoonBitLibrary from "../../../target/js/release/build/router";

MyMoonBitLibrary.init_database((db) => {
    console.log("Database initialized:", db);
}, (err) => {
    console.error("Error initializing database:", err);
});

const router = MyMoonBitLibrary.handle_fetch_router();
Bun.serve({
    fetch: async (req) => {
        return new Promise<any>((resolve) => {
            MyMoonBitLibrary.handle_request_by_router(router, req, (response) => {
                resolve(response);
            }, (err) => {
                console.error("Error:", err);
                resolve(new Response("Internal Server Error", { status: 500 }));
            });
        })
    },
});