use worker::*;
use serde::{Deserialize, Serialize};
use hmac::{Hmac, Mac};
use sha2::{Sha256, Digest};
use chrono::Utc;

type HmacSha256 = Hmac<Sha256>;

#[derive(Deserialize)]
struct UploadRequest {
    filename: String,
    content_type: String,
    // Type of upload: barcode, price, product
    upload_type: UploadType,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
enum UploadType {
    Barcode,
    Price,
    Product,
}

#[derive(Serialize)]
struct UploadResponse {
    upload_url: String,
    public_url: String,
    expires_at: i64,
}

#[derive(Serialize)]
struct ErrorResponse {
    error: String,
}

fn get_prefix(upload_type: &UploadType) -> &'static str {
    match upload_type {
        UploadType::Barcode => "barcodes",
        UploadType::Price => "prices",
        UploadType::Product => "products",
    }
}

fn validate_content_type(content_type: &str) -> bool {
    matches!(content_type, "image/avif" | "image/webp" | "image/jpeg" | "image/png")
}

fn generate_presigned_url(
    bucket_name: &str,
    key: &str,
    content_type: &str,
    access_key: &str,
    secret_key: &str,
    expires_in_secs: i64,
) -> Result<(String, i64)> {
    let now = Utc::now();
    let expires_at = now.timestamp() + expires_in_secs;
    let date_stamp = now.format("%Y%m%d").to_string();
    let amz_date = now.format("%Y%m%dT%H%M%SZ").to_string();
    let region = "auto";
    let service = "s3";

    let credential_scope = format!("{}/{}/{}/aws4_request", date_stamp, region, service);

    // Canonical request components
    let host = format!("{}.r2.cloudflarestorage.com", bucket_name);
    let canonical_uri = format!("/{}", key);

    let canonical_headers = format!(
        "content-type:{}\nhost:{}\nx-amz-date:{}\n",
        content_type, host, amz_date
    );
    let signed_headers = "content-type;host;x-amz-date";

    let canonical_request = format!(
        "PUT\n{}\n\n{}\n{}\nUNSIGNED-PAYLOAD",
        canonical_uri, canonical_headers, signed_headers
    );

    // String to sign
    let canonical_request_hash = hex::encode(sha2::Sha256::digest(canonical_request.as_bytes()));
    let string_to_sign = format!(
        "AWS4-HMAC-SHA256\n{}\n{}\n{}",
        amz_date, credential_scope, canonical_request_hash
    );

    // Calculate signature
    fn hmac_sha256(key: &[u8], data: &[u8]) -> Vec<u8> {
        let mut mac = HmacSha256::new_from_slice(key).expect("HMAC can take key of any size");
        mac.update(data);
        mac.finalize().into_bytes().to_vec()
    }

    let date_key = hmac_sha256(format!("AWS4{}", secret_key).as_bytes(), date_stamp.as_bytes());
    let date_region_key = hmac_sha256(&date_key, region.as_bytes());
    let date_region_service_key = hmac_sha256(&date_region_key, service.as_bytes());
    let signing_key = hmac_sha256(&date_region_service_key, b"aws4_request");
    let signature = hex::encode(hmac_sha256(&signing_key, string_to_sign.as_bytes()));

    // Build presigned URL with query parameters
    let url = format!(
        "https://{}/{}?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential={}/{}&X-Amz-Date={}&X-Amz-Expires={}&X-Amz-SignedHeaders={}&X-Amz-Signature={}",
        host,
        key,
        access_key,
        credential_scope.replace('/', "%2F"),
        amz_date,
        expires_in_secs,
        signed_headers,
        signature
    );

    Ok((url, expires_at))
}

#[event(fetch)]
async fn main(req: Request, env: Env, _ctx: Context) -> Result<Response> {
    // Only allow POST requests
    if req.method() != Method::Post {
        return Response::error("Method not allowed", 405);
    }

    // Parse request body
    let mut req = req;
    let body: UploadRequest = match req.json().await {
        Ok(b) => b,
        Err(_) => {
            return Ok(Response::from_json(&ErrorResponse {
                error: "Invalid request body".to_string(),
            })?.with_status(400));
        }
    };

    // Validate content type
    if !validate_content_type(&body.content_type) {
        return Ok(Response::from_json(&ErrorResponse {
            error: "Invalid content type. Only AVIF, WebP, JPEG, PNG allowed.".to_string(),
        })?.with_status(400));
    }

    // Get R2 credentials from environment
    let bucket_name = env.var("R2_BUCKET_NAME")?.to_string();
    let access_key = env.secret("R2_ACCESS_KEY_ID")?.to_string();
    let secret_key = env.secret("R2_SECRET_ACCESS_KEY")?.to_string();
    let public_url_base = env.var("R2_PUBLIC_URL")?.to_string();

    // Generate unique key with timestamp
    let timestamp = Utc::now().timestamp_millis();
    let prefix = get_prefix(&body.upload_type);
    let key = format!("{}/{}-{}", prefix, timestamp, body.filename);

    // Generate presigned URL (valid for 5 minutes)
    let (upload_url, expires_at) = generate_presigned_url(
        &bucket_name,
        &key,
        &body.content_type,
        &access_key,
        &secret_key,
        300,
    )?;

    let public_url = format!("{}/{}", public_url_base, key);

    Response::from_json(&UploadResponse {
        upload_url,
        public_url,
        expires_at,
    })
}
