use worker::*;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct ShoppingList {
    id: String,
    owner_id: String,
    name: String,
    description: Option<String>,
}

#[derive(Deserialize)]
struct CreateListRequest {
    name: String,
    description: Option<String>,
}

#[derive(Serialize)]
struct ErrorResponse {
    error: String,
}

fn get_user_id(req: &Request) -> Result<String> {
    req.headers()
        .get("X-User-Id")?
        .ok_or_else(|| Error::RustError("Missing user ID".into()))
}

#[event(fetch)]
async fn main(req: Request, env: Env, _ctx: Context) -> Result<Response> {
    let router = Router::new();

    router
        .get("/health", |_, _| Response::ok("OK"))
        .get_async("/lists", |req, ctx| async move {
            let _user_id = get_user_id(&req)?;

            // D1 binding - actual implementation depends on worker crate version
            // For now return placeholder
            Response::from_json(&serde_json::json!({
                "data": [],
                "message": "D1 integration pending - requires worker crate update"
            }))
        })
        .post_async("/lists", |mut req, _ctx| async move {
            let _user_id = get_user_id(&req)?;
            let body: CreateListRequest = req.json().await?;

            // Placeholder - D1 write
            Response::from_json(&serde_json::json!({
                "id": "placeholder",
                "name": body.name
            }))
        })
        .run(req, env)
        .await
}
