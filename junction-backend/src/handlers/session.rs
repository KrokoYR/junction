use crate::error::AppError;
use crate::models::session::CreateSessionResponse;
use crate::AppState;
use axum::extract::Query;
use axum::http::StatusCode;
use axum::{extract::State, http::header::SET_COOKIE, response::IntoResponse, Json};
use axum_extra::extract::CookieJar;
use base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use chrono::{DateTime, Duration, Utc};
use hmac::{Hmac, Mac};
use jsonwebtoken::{encode, EncodingKey, Header};
use rand::{rngs::OsRng, RngCore};
use serde::{Deserialize, Serialize};
use sha2::Sha256;

pub const SESSION_COOKIE_NAME: &str = "fin_zero_session";
pub const AUTH_COOKIE_NAME: &str = "fin_zero_auth";

pub async fn session_create(
    State(state): State<AppState>,
    jar: CookieJar,
) -> Result<impl IntoResponse, AppError> {
    if let Some(_) = jar.get(SESSION_COOKIE_NAME) {
        return Err(AppError::CustomError(
            StatusCode::CONFLICT,
            "Session already exists".to_string(),
        ));
    }

    let mut random_bytes = [0u8; 32];
    OsRng.fill_bytes(&mut random_bytes);
    let session_key = BASE64.encode(random_bytes);

    let dur = Duration::hours(24);
    let expires_at: DateTime<Utc> = Utc::now() + dur;

    let session =
        crate::db::session::save_session(&state.pool, session_key.clone(), expires_at).await?;

    let secret_key = std::env::var("SESSION_SECRET_KEY").expect("SESSION_SECRET_KEY must be set");
    let hashed_session = hash_session_key(&session.id.to_string(), &secret_key);

    let response_body = CreateSessionResponse {
        session_key: session.session_key,
        expires_at: session.expires_at.unwrap_or_else(|| Utc::now()),
    };

    let cookie = format!(
        "fin_zero_session={}; HttpOnly; Secure; SameSite=None; Path=/; Max-Age={}",
        hashed_session,
        dur.num_seconds()
    );

    Ok(([(SET_COOKIE, cookie)], Json(response_body)))
}

fn hash_session_key(session_key: &str, secret_key: &str) -> String {
    type HmacSha256 = Hmac<Sha256>;

    let mut mac =
        HmacSha256::new_from_slice(secret_key.as_bytes()).expect("HMAC can take key of any size");

    mac.update(session_key.as_bytes());

    let result = mac.finalize();
    let code_bytes = result.into_bytes();

    BASE64.encode(code_bytes)
}
// JWT Claims structure
#[derive(Debug, Serialize, Deserialize)]
struct AuthClaims {
    sub: String, // Subject (user/session ID)
    exp: i64,    // Expiration time
    iat: i64,    // Issued at
}

#[derive(Serialize)]
pub struct SessionVerificationResponse {
    is_verified: bool,
}

// Define a struct for query parameters
#[derive(Deserialize)]
pub struct SessionQuery {
    session_key: String,
}

pub async fn is_session_verified(
    State(state): State<AppState>,
    jar: CookieJar,
    Query(query): Query<SessionQuery>,
) -> Result<impl IntoResponse, (StatusCode, AppError)> {
    let session_key = query.session_key;
    let session_cookie = jar
        .get(SESSION_COOKIE_NAME)
        .map(|cookie| cookie.value().to_string())
        .ok_or_else(|| {
            (
                StatusCode::UNAUTHORIZED,
                AppError::Validation("Session cookie not found".to_string()),
            )
        })?;
    let secret_key = std::env::var("SESSION_SECRET_KEY").map_err(|_| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            AppError::Internal("Server configuration error".to_string()),
        )
    })?;

    println!("Session key: {}", session_key);
    let session = crate::db::session::get_session_by_key(&state.pool, session_key)
        .await
        .map_err(|e| {
            let err_text = "DB: Invalid session: ".to_string();
            (StatusCode::UNAUTHORIZED, AppError::Validation(err_text))
        })?;
    if let Some(expires_at) = session.expires_at {
        if expires_at <= Utc::now() {
            return Err((
                StatusCode::UNAUTHORIZED,
                AppError::Validation("Session expired".to_string()),
            ));
        }
    } else {
        return Err((
            StatusCode::UNAUTHORIZED,
            AppError::Validation("No expiration. Invalid session".to_string()),
        ));
    }

    let hashed_session = hash_session_key(&session.id.to_string(), &secret_key);
    if session_cookie != hashed_session {
        return Err((
            StatusCode::UNAUTHORIZED,
            AppError::Validation("Invalid hash".to_string()),
        ));
    }

    let dur = session.expires_at.unwrap() - Utc::now();
    let max_age = dur.num_seconds();

    // Session cookie
    let session_cookie = format!(
        "{}={}; HttpOnly; Secure; SameSite=None; Path=/; Max-Age={}",
        SESSION_COOKIE_NAME, hashed_session, max_age
    );

    // Auth cookie with JWT (only set if session is verified)
    let auth_cookie = if session.is_verified.unwrap_or(false) {
        // Create JWT token
        let auth_claims = AuthClaims {
            sub: session.id.to_string(),
            exp: (Utc::now() + dur).timestamp(),
            iat: Utc::now().timestamp(),
        };

        let auth_secret = std::env::var("AUTH_SECRET_KEY").map_err(|_| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                AppError::Internal("Server configuration error".to_string()),
            )
        })?;

        let token = encode(
            &Header::default(),
            &auth_claims,
            &EncodingKey::from_secret(auth_secret.as_bytes()),
        )
        .map_err(|_| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                AppError::Validation("Failed to create auth token".to_string()),
            )
        })?;

        format!(
            "{}={}; HttpOnly; Secure; SameSite=None; Path=/; Max-Age={}",
            AUTH_COOKIE_NAME, token, max_age
        )
    } else {
        // If not verified, clear the auth cookie if it exists
        format!(
            "{}=; HttpOnly; Secure; SameSite=None; Path=/; Max-Age=0",
            AUTH_COOKIE_NAME
        )
    };

    Ok((
        [(SET_COOKIE, session_cookie), (SET_COOKIE, auth_cookie)],
        Json(SessionVerificationResponse {
            is_verified: session.is_verified.unwrap_or(false),
        }),
    ))
}
