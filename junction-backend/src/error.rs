use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("Validation error: {0}")]
    Validation(String),

    #[error("Authentication error: {0}")]
    Authentication(String),

    #[error("Rate limit exceeded")]
    RateLimit,

    #[error("Internal server error")]
    Internal(String),

    #[error("Invalid signature: {0}")]
    InvalidSignature(String),

    #[error("Custom error: {0}, {1}")]
    CustomError(StatusCode, String),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, error_message) = match self {
            AppError::Database(ref e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()),
            AppError::Validation(ref e) => (StatusCode::BAD_REQUEST, e.to_string()),
            AppError::Authentication(ref e) => (StatusCode::UNAUTHORIZED, e.to_string()),
            AppError::RateLimit => (
                StatusCode::TOO_MANY_REQUESTS,
                "Rate limit exceeded".to_string(),
            ),
            AppError::Internal(ref e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()),
            AppError::InvalidSignature(ref e) => (StatusCode::BAD_REQUEST, e.to_string()),
            AppError::CustomError(status, ref e) => (status, e.to_string()),
        };

        let body = Json(json!({
            "error": error_message
        }));

        (status, body).into_response()
    }
}
